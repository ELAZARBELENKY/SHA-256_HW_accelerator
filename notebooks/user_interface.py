from pynq import Overlay
from pynq.lib.dma import DMA
from pynq import allocate
import numpy as np
import struct
import time
from hashlib import sha256
import os
 
def calculate_sha256_hardware(filepath: str) -> tuple:
 
    def sha256_pad(message: bytes) -> np.ndarray:
        length = len(message) * 8
        message += b'\x80'
        while (len(message) % 64) != 56:
            message += b'\x00'
        message += struct.pack('>Q', length)
        return np.frombuffer(message, dtype='>u4')
 
    overlay = Overlay("SHA256_BlockDesign_wrapper.bit")
    dma = overlay.axi_dma_0
 
    with open(filepath, "rb") as f:
        data = f.read()
    input_data = sha256_pad(data)
 
    data_buffer = allocate(shape=(len(input_data),), dtype=np.uint32)
    output_buffer = allocate(shape=(8,), dtype=np.uint32)
    np.copyto(data_buffer, input_data)
 
    start_time = time.time()
    dma.sendchannel.transfer(data_buffer)
    dma.sendchannel.wait()
    dma.recvchannel.transfer(output_buffer)
    dma.recvchannel.wait()
    execution_time = time.time() - start_time
 
    sha256_result = ''.join(f'{word:08x}' for word in output_buffer.tolist())
    return sha256_result, execution_time
 
def calculate_sha256_software(filepath: str) -> tuple:
 
    with open(filepath, "rb") as f:
        data = f.read()
    
    start_time = time.time()
    sha256_result = sha256(data).hexdigest()
    execution_time = time.time() - start_time
    
    return sha256_result, execution_time
 
def list_available_images():
    pictures_dir = "pictures"
    if not os.path.exists(pictures_dir):
        print(f"\nError: '{pictures_dir}' folder not found!")
        return []
    
    image_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.webp']
    all_files = os.listdir(pictures_dir)
    images = []
    for file in all_files:
        file_lower = file.lower()
        for ext in image_extensions:
            if file_lower.endswith(ext):
                images.append(file)
                break
    if not images:
        print(f"\nNo image files found in '{pictures_dir}' folder!")
        return []
    
    print("\nAvailable images:")
    for i, img in enumerate(images, 1):
        filename, extension = os.path.splitext(img)
        print(f"{i}. {filename}")
    return images
 
def main():
    print("=" * 80, 
    "                        SHA-256 Hardware Accelerator", 
    "              Calculate SHA-256 hash using FPGA acceleration", 
    "=" * 80, sep="\n")
 
    while True:
        images = list_available_images()
        if not images:
            return
 
        print("\nEnter image name or number (or 'q' to quit)")
        choice = input("Choice: ").strip()
        
        if choice.lower() == 'q':
            print("\nExiting program...")
            return
 
        if choice.isdigit():
            idx = int(choice) - 1
            if 0 <= idx < len(images):
                filename = images[idx]
            else:
                print("\nError: Invalid number! Please try again.")
                continue
        else:
            found = False
            if choice in images:
                filename = choice
                found = True
            else:
                for img in images:
                    name_without_ext, _ = os.path.splitext(img)
                    if name_without_ext == choice:
                        filename = img
                        found = True
                        break
            if not found:
                print("\nError: Image not found! Please try again.")
                continue
 
        filepath = os.path.join("pictures", filename)
        break
 
    display_name, _ = os.path.splitext(filename)
    print(f"\nProcessing {display_name}...")
    
    print("Calculating hardware hash...")
    hw_hash, hw_time = calculate_sha256_hardware(filepath)
    
    print("Calculating software hash...")
    sw_hash, sw_time = calculate_sha256_software(filepath)
 
    filesize = os.path.getsize(filepath)
    
    print(f"""Results:
    {"=" * 80}
    File: {os.path.basename(filepath)}
    Size: {filesize:,} bytes
    
    Hardware Hash:
    {hw_hash}
    Hardware Time: {hw_time:.6f} seconds
    
    Software Hash:
    {sw_hash}
    Software Time: {sw_time:.6f} seconds
    
    Speedup: {sw_time/hw_time:.2f}x
    {"=" * 80}""")
 
    if hw_hash == sw_hash:
        print("✓ Hashes match! Hardware acceleration successful!")
    else:
        print("⚠ Warning: Hardware and software hashes don't match!")
    print()
 
if __name__ == "__main__":
     main()
