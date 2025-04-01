<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Google tag (gtag.js) -->
    <script async src="https://www.googletagmanager.com/gtag/js?id=G-T39HDMPC30"></script>
    <script>
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());

      gtag('config', 'G-T39HDMPC30');
    </script>
    <title>ASAI Suite 主題套餐</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            min-height: 100vh;
            background-color: #ffffff;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        a:link { 
           text-decoration: none; 
        } 
        a:visited { 
          text-decoration: none; 
        } 
        a:hover { 
          text-decoration: none; 
        } 
        a:active { 
          text-decoration: none; 
        }

        .container {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: 100%;
            padding: 2rem;
        }

        .logo {
            display: flex;
            margin-bottom: 4rem;
            padding: 0.75rem 2rem;
            text-align: center;
            min-width: 520px;
        }

        .features {
            display: flex;
            gap: 2rem;
            flex-wrap: wrap;
            justify-content: center;
            align-items: center;
            max-width: 1200px;
        }

        .feature-itemx {
           background-color:#FFF;
           display: flex;
           flex-direction: column;
           align-items: center;
           gap: 0.5rem;
           width: 140px;
           /* filter: blur(4px); */
        }

        .feature-item {
           display: flex;
           flex-direction: column;
           align-items: center;
           gap: 0.5rem;
           width: 160px;
           cursor: pointer;
        }

        .feature-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
        }

        .feature-text {
           font-size: 1rem;
           color: #333;
           text-align: center;
        }

        /* Feature specific colors */
        .translate .feature-icon {
            /* background-color: #8BC8B1; */
        }
        .translate .feature-icon:hover {
           background-color: #6DA88F;
           transform: scale(1.1);
        }

        .subtitle .feature-icon {
            /* background-color: #FFA500; */
        }
        .subtitle .feature-icon:hover {
           background-color: #E69400;
           transform: scale(1.1);
        }

        .summary .feature-icon {
            /* background-color: #5ECCC6;*/
        }
        .summary .feature-icon:hover {
           background-color: #4BA8A3;
           transform: scale(1.1);
        }

        .assistant .feature-icon {
            /*background-color: #9B6B9E;*/
        }
        .assistant .feature-icon:hover {
           background-color: #7D557F;
           transform: scale(1.1);
        }
        .divid {
           position: fixed;
           top: 0;
           right: 0;
           transform: translateX(-50%);
           padding: 4px;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
           body {
              align-items: flex-start;
           }
           .container {
              justify-content: flex-start;
              padding-top: 1rem;
           }
            .logo {
               min-width:420px;
            }
            .features {
                gap: 1.5rem;
            }

            .feature-icon {
                width: 60px;
                height: 60px;
            }

            .feature-item {
                width: 100px;
            }
        }

        @media (max-width: 480px) {
            .features {
                flex-direction: column;
                align-items: center;
                gap: 2rem;
            }

            .feature-item {
                width: 100%;
                max-width: 200px;
            }

            .logo {
                margin-bottom: 3rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">
           <img src="images/suitemain.svg" />
        </div>
        
        <div class="features">
           <div class="feature-itemx translate">
              <div class="feature-icon"><img src="images/txt-gray.svg"></div>
              <div class="feature-text">AI 翻譯</div>
           </div>
           <a href="www/translate">
           <div class="feature-item subtitle">
              <div class="feature-icon"><img src="images/transcription.svg"></div>
              <div class="feature-text">AI 逐字稿（測試版）</div>
           </div>
           </a>
            <div class="feature-itemx assistant">
                <div class="feature-icon"><img src="images/littlehelper.svg"></div>
                <div class="feature-text">AI 小幫手</div>
            </div>
        </div>
        <div class="divid">
           {{ .Userinfo.ChName }}（{{ .Userinfo.Email }}） 您好
           <a href="/homepage/en">English</a> | 
           <a href="/logout">Logout</a>
        </div>
    </div>
</body>
</html>
