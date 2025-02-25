# BPSK Audio Transmission and Reconstruction

## Overview
This project implements a Binary Phase Shift Keying (BPSK) communication system using MATLAB. The process includes:

1. **Audio to Digital Conversion**  
2. **BPSK Encoding**  
3. **Line Coding (Rectangular & Raised Cosine Pulses)**  
4. **Modulation**  
5. **Transmission through an AWGN Channel**  
6. **Demodulation & Decoding**  
7. **Reconstruction of the Audio Signal**  

All figures are stored in the `plots` folder.

---

## System Parameters:
- **Sample rate:** 48,000 Hz  
- **SNR:** 23.5003  
- **Signal Power:** 1  
- **Noise Power:** 0.042553  
- **SNR in dB:** 13.7107  
- **Bit Error Rate (BER):**  
  - Rectangular: 0.25966  
  - Raised Cosine: 0.26304  

---

## Process Flow

### 1. Audio to Digital Conversion
- The input audio (`project.wav`) is read and normalized.  
- It is **quantized** using an 8-bit representation.  
- The resulting **binary stream** is extracted.

### 2. BPSK Encoding
- The **binary stream** is mapped to a BPSK signal using \( s = 2b - 1 \).  
- Signal-to-noise ratio (SNR) is calculated.  

### 3. Line Coding
- **Rectangular pulse shaping** and **raised cosine pulse shaping** are applied.  
- Raised cosine filtering reduces **inter-symbol interference (ISI)**.

### 4. Modulation
- The shaped signals are modulated using a **carrier frequency** of 1 kHz.  
- The **rectangular and raised cosine modulated signals** are stored.  

#### Modulation Plots:
![Modulation](plots/Modulation.png)

---

### 5. Transmission through AWGN Channel
- White Gaussian noise (AWGN) is added to simulate a real channel.  
- The received signals (without memory effects) are stored.

#### Memoryless Channel:
![Memoryless Channel](plots/Memoryless_Channel.png)

---

### 6. Constellation Diagrams
- Input and output constellation diagrams show the signal degradation.

#### Constellation Diagram:
![Constellation Diagram](plots/constellation_plot.png)

---

### 7. Demodulation & Decoding
- The received signals are **demodulated** using coherent detection.
- A **low-pass filter (Kaiser window)** extracts the baseband signal.

#### Mixed and Filtered Signals:
![Mixed and Filtered Signals](plots/Mix_and_Filter.png)

---

### 8. Line Decoding
- The **BPSK signal is reconstructed** and sampled.

#### Sampled Line Decoded Signals:
![Line Decoded](plots/Line_Decoded.png)

---

### 9. BPSK Decoding & Audio Reconstruction
- A **thresholding method** decodes bits.
- The received binary sequence is **converted back to an audio signal**.

#### Reconstructed vs. Original Audio Signal:
![Reconstructed Audio](plots/Reconstructed.png)

---

## Output Files:
- **Reconstructed Audio (Sampled):**
  - `reconstructed_rect.wav` (Rectangular Pulse)
  - `reconstructed_rc.wav` (Raised Cosine Pulse)

---

## Observations
- Raised Cosine filtering **improves ISI reduction** but has a slightly higher BER.
- The rectangular pulse method results in **higher bit errors** but a simpler implementation.
- The BPSK signal integrity is **affected by AWGN**, as seen in the constellation diagrams.

---

## Conclusion
This implementation showcases a **basic BPSK transmission system**, comparing **rectangular and raised cosine pulse shaping techniques**.  

The trade-off between **ISI reduction and BER performance** is evident, highlighting the importance of pulse shaping in digital communication.
