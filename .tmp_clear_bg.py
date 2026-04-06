from collections import deque
from pathlib import Path
import numpy as np
from PIL import Image

paths = [
    Path('assets/images/Mascota/mascota_stage1.png'),
    Path('assets/images/Mascota/mascota_stage2.png'),
    Path('assets/images/Mascota/mascota_stage3.png'),
    Path('assets/images/Mascota/mascota_stage4.png'),
]

EDGE_THRESH = 28  # color distance threshold per channel

for path in paths:
    img = Image.open(path).convert('RGBA')
    arr = np.array(img)
    rgb = arr[:, :, :3].astype(np.int16)
    h, w, _ = rgb.shape
    bg = rgb[0, 0]
    sq_thresh = (EDGE_THRESH ** 2) * 3

    dist = np.sum((rgb - bg) ** 2, axis=2)
    near = dist <= sq_thresh

    mask = np.zeros((h, w), dtype=bool)
    q = deque()

    # enqueue edge pixels that are near bg
    for x in range(w):
        if near[0, x]:
            mask[0, x] = True; q.append((0, x))
        if near[h - 1, x]:
            mask[h - 1, x] = True; q.append((h - 1, x))
    for y in range(h):
        if near[y, 0]:
            mask[y, 0] = True; q.append((y, 0))
        if near[y, w - 1]:
            mask[y, w - 1] = True; q.append((y, w - 1))

    # flood fill through near-bg pixels
    while q:
        y, x = q.popleft()
        for dy, dx in ((1,0),(-1,0),(0,1),(0,-1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and not mask[ny, nx] and near[ny, nx]:
                mask[ny, nx] = True
                q.append((ny, nx))

    # make bg transparent with slight feather at edges
    alpha = arr[:, :, 3].astype(np.int16)
    alpha[mask] = 0

    # feather one pixel to soften edge
    kernel = np.array([[0,1,0],[1,1,1],[0,1,0]], dtype=bool)
    expanded = np.logical_and(~mask, np.logical_and.reduce([
        np.pad(mask[1:, :], ((0,1),(0,0)), constant_values=False),  # up
        np.pad(mask[:-1, :], ((1,0),(0,0)), constant_values=False), # down
        np.pad(mask[:, 1:], ((0,0),(0,1)), constant_values=False), # left
        np.pad(mask[:, :-1], ((0,0),(1,0)), constant_values=False) # right
    ]))
    # simpler feather: any non-mask pixel touching mask lowers alpha
    touch = np.zeros_like(mask)
    for dy, dx in ((1,0),(-1,0),(0,1),(0,-1)):
        shifted = np.zeros_like(mask)
        if dy == 1:
            shifted[1:, :] = mask[:-1, :]
        elif dy == -1:
            shifted[:-1, :] = mask[1:, :]
        elif dx == 1:
            shifted[:, 1:] = mask[:, :-1]
        else:
            shifted[:, :-1] = mask[:, 1:]
        touch |= shifted
    feather = touch & ~mask
    alpha[feather] = np.minimum(alpha[feather], 180)

    arr[:, :, 3] = alpha.astype(np.uint8)
    out = Image.fromarray(arr, 'RGBA')
    out.save(path, optimize=True)
    print(f"Processed {path} -> transparent bg")
