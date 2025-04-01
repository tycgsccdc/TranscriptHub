package main

import (
   // "io"
   "os"
   "fmt"
   "time"
   "strings"
   "os/exec"
   "path/filepath"
   "github.com/faiface/beep"
   "github.com/faiface/beep/mp3"
   "github.com/faiface/beep/wav"
)

func formatDuration(d time.Duration)(string){
   d = d.Round(time.Second)
   h := d / time.Hour
   d -= h * time.Hour
   m := d / time.Minute
   d -= m * time.Minute
   s := d / time.Second
   if h > 0 {
      return fmt.Sprintf("%02d:%02d:%02d", h, m, s)
   }
   return fmt.Sprintf("%02d:%02d", m, s)
}

// 使用 tag 庫計算音頻文件時間長度（MP3）
func getDuration(streamer beep.StreamSeekCloser, format beep.Format)(time.Duration , error) {
   samples := streamer.Len()
   seconds := float64(samples) / float64(format.SampleRate)
   duration := time.Duration(seconds * float64(time.Second))
   return duration, nil
}

// GetMP4Duration 計算MP4文件的時間
func CountDuration(filename string) (string, error) {
   extension := strings.ToLower(filepath.Ext(filename))
   audioPath := ""
   if extension == ".mp4" {
      tempDir := os.TempDir()
      audioPath = filepath.Join(tempDir, filename + ".mp3")
      extractCmd := exec.Command("ffmpeg", "-i", filename, "-q:a", "0", "-map", "a", audioPath)
      if err := extractCmd.Run(); err != nil {
         return "", err
      }
      extension = ".mp3"
      filename = audioPath
   }
   f, err := os.Open(filename)
   if err != nil {
      return "", fmt.Errorf("無法開啟文件: %s", err.Error())
   }
   defer f.Close()
   if audioPath != "" {
      defer os.Remove(audioPath) // 程式結束時刪除臨時檔案
   }
   var streamer beep.StreamSeekCloser
   var format beep.Format
   if extension == ".wav" {
      streamer, format, err = wav.Decode(f)  // beep.StreamSeekCloser, format beep.Format, err error
   } else if extension == ".mp3" {
      streamer, format, err = mp3.Decode(f)  // beep.StreamSeekCloser, format beep.Format, err error
   }
   if err != nil {
      return "", err
   }
   defer streamer.Close()
   duration, err := getDuration(streamer, format)
   if err != nil {
      return "", err
   }
   return formatDuration(duration), nil
}

// 偵測長度1小時
func isLimit(filename string)(bool) {
   return true
}
