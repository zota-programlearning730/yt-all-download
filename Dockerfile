FROM python:3.9-slim

# 安裝 FFmpeg (下載轉 MP3/MP4 必須)
# 這裡沒變，保持原樣
RUN apt-get update && \
    apt-get install -y ffmpeg && \
    apt-get clean

WORKDIR /app

# === 修改建議 1：加入這個設定 ===
# 讓 Python 的 print 訊息可以即時顯示在 Render 的 Log 中
# 這樣如果卡住或報錯，你才看得到進度
ENV PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p temp_downloads

# 設定環境變數 PORT，預設 10000
ENV PORT=10000

# === 修改建議 2：大幅增加 timeout ===
# 原本是 300 (5分鐘)，但現在我們要「批次下載」多個檔案 + 搜尋歌詞
# 如果一次下載 5-10 首歌，5分鐘很容易就超時被踢掉
# 建議改成 1000 或更高
CMD gunicorn -w 2 -b 0.0.0.0:$PORT app:app --timeout 1000