from pynq import Overlay
from pynq.lib.dma import DMA
from pynq import allocate
import numpy as np
import struct
import time
from hashlib import sha256
import os
import matplotlib.pyplot as plt
from statistics import mean, stdev

ITERATIONS = 50

# SHA-256 Padding
def sha256_pad(message: bytes) -> np.ndarray:
    length = len(message) * 8
    message += b'\x80'
    while (len(message) % 64) != 56:
        message += b'\x00'
    message += struct.pack('>Q', length)
    return np.frombuffer(message, dtype='>u4')

# Hardware SHA-256 Calculation
def calculate_sha256_hardware(filepath: str) -> tuple:
    overlay = Overlay("SHA256_Block_Design.bit")
    dma = overlay.axi_dma_0
    
    with open(filepath, "rb") as f:
        data = f.read()
    
    input_data = sha256_pad(data)
    data_buffer = allocate(shape=(len(input_data),), dtype=np.uint32)
    output_buffer = allocate(shape=(8,), dtype=np.uint32)
    
    execution_times = []
    for _ in range(ITERATIONS):
        np.copyto(data_buffer, input_data)
        start_time = time.time()
        dma.sendchannel.transfer(data_buffer)
        dma.sendchannel.wait()
        dma.recvchannel.transfer(output_buffer)
        dma.recvchannel.wait()
        execution_times.append(time.time() - start_time)
    
    del data_buffer, output_buffer
    return mean(execution_times), stdev(execution_times), len(data)

# Software SHA-256 Calculation
def calculate_sha256_software(filepath: str) -> tuple:
    with open(filepath, "rb") as f:
        data = f.read()
    
    execution_times = []
    for _ in range(ITERATIONS):
        start_time = time.time()
        sha256(data).hexdigest()
        execution_times.append(time.time() - start_time)
    
    return mean(execution_times), stdev(execution_times), len(data)

# Generate Test Files
def create_test_files():
    sizes = [10, 100, 1000, 10000, 45000, 100000, 500000, 1_000_000,
             2_000_000, 4_000_000, 8_000_000, 16_000_000, 23_000_000]
    test_dir = "test_files"
    os.makedirs(test_dir, exist_ok=True)
    
    files = []
    for size in sizes:
        filepath = os.path.join(test_dir, f"test_{size}_bytes.txt")
        if not os.path.exists(filepath) or os.path.getsize(filepath) != size:
            with open(filepath, "wb") as f:
                f.write(b'A' * size)
        files.append(filepath)
    
    return files

# Benchmark and Plot Results
def benchmark():
    print("Starting calculation")
    files = create_test_files()
    results = []
    
    for filepath in files:
        hw_mean, hw_std, filesize = calculate_sha256_hardware(filepath)
        sw_mean, sw_std, _ = calculate_sha256_software(filepath)
        speedup = sw_mean / hw_mean
        results.append((filesize, hw_mean, hw_std, sw_mean, sw_std, speedup))
    
    results.sort()
    sizes, hw_times, hw_errors, sw_times, sw_errors, speedups = zip(*results)
    
    plt.figure(figsize=(12, 15))
    
    plt.subplot(3, 1, 1)
    plt.errorbar(sizes, hw_times, yerr=hw_errors, fmt='o-', label='Hardware', capsize=5)
    plt.errorbar(sizes, sw_times, yerr=sw_errors, fmt='o-', label='Software', capsize=5)
    plt.xscale('log')
    plt.yscale('log')
    plt.xlabel('Data Size (bytes)')
    plt.ylabel('Execution Time (seconds)')
    plt.title('SHA-256 Performance Comparison')
    plt.legend()
    plt.grid(True, which="both", ls="--")
    
    plt.subplot(3, 1, 2)
    plt.plot(sizes, speedups, 'o-', color='green')
    plt.axhline(y=1.0, color='r', linestyle='--', alpha=0.7)
    plt.xscale('log')
    plt.xlabel('Data Size (bytes)')
    plt.ylabel('Speedup (Software/Hardware)')
    plt.title('Hardware Acceleration Speedup')
    plt.grid(True, which="both", ls="--")
    
    plt.subplot(3, 1, 3)
    hw_time_per_byte = [t/s for t, s in zip(hw_times, sizes)]
    sw_time_per_byte = [t/s for t, s in zip(sw_times, sizes)]
    
    plt.plot(sizes, hw_time_per_byte, 'o-', label='Hardware Time per Byte')
    plt.plot(sizes, sw_time_per_byte, 'o-', label='Software Time per Byte')
    plt.xscale('log')
    plt.yscale('log')
    plt.xlabel('Data Size (bytes)')
    plt.ylabel('Time per Byte (seconds)')
    plt.title('Normalized Processing Time')
    plt.legend()
    plt.grid(True, which="both", ls="--")
    
    plt.tight_layout()
    plt.savefig('sha256_performance.png')
    plt.show()

benchmark()