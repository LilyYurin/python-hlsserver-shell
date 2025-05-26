# How to Use and Understand the HLS Streaming Script

## Purpose of the Script

This script takes an MP4 video file and generates multiple HLS (HTTP Live Streaming) video streams at different resolutions and bitrates. It then launches a simple HTTP server to serve the generated content.

---

## Prerequisites

The following tools are required to run this script:

- `bash` (shell)
- `ffmpeg` (for video encoding)
- `python3` (for HTTP server)

Installation example (Ubuntu/Debian):

```bash
sudo apt update
sudo apt install ffmpeg python3
```

---

## How to Run

### Basic usage (default port: 8080)

```bash
./python-hlsserver.bash
```

### Specify a custom port number (e.g., port 8000)

```bash
./python-hlsserver.bash 8000
```

---

## Description of Configuration Parameters

| Parameter         | Description                                             | Default Value          |
| ----------------- | ------------------------------------------------------- | ---------------------- |
| `INPUT_FILE`      | Name of the input video file                           | `test.mp4`             |
| `OUTPUT_DIR`      | Directory to save HLS files                            | input filename + `_hls`|
| `PORT`            | Port number for the HTTP server                        | 8080                   |
| `HLS_PREFIX`      | Base URL for each stream in the master playlist        | `http://10.0.0.1:${PORT}` |

---

##  Script Behavior (Step-by-Step)

### 1. Input file and output directory
- Uses the base name of the input file (without extension) to create an output directory.
- If the directory already exists, the script skips re-encoding and serves existing files.

### 2. Generate HLS video streams (multiple resolutions)
- Generates HLS streams for the following resolutions and bitrates:
  - 1280x720 (3000 kbps)
  - 854x480 (1500 kbps)
  - 640x360 (800 kbps)
  - 426x240 (400 kbps)

- Each stream is encoded using `ffmpeg` and saved as `.m3u8` and `.ts` files in the output directory.

### 3. Create master playlist (`master.m3u8`)
- A master playlist that lists all available stream variants is created.
- Clients can use this playlist to automatically select the appropriate resolution.

### 4. Launch HTTP server
- A simple HTTP server is started using Python on the specified port to serve the HLS files.

---

## How to View the Stream

Access the master playlist at:

```
http://<server-ip>:<port>/master.m3u8
```

Example: `http://10.0.0.1:8080/master.m3u8`
