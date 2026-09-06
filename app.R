library(shiny)

# =========================================================
# واجهة التطبيق
# =========================================================

ui <- fluidPage(
  
  tags$head(
    
    tags$style(HTML("

      /* =====================================================
         الصفحة والخلفية
         ===================================================== */

      html, body {
        margin: 0;
        padding: 0;
        width: 100%;
        height: 100%;
        overflow: hidden;
    

      body {
        background-image: url('background.png');
        background-size: cover;
        background-position: center center;
        background-repeat: no-repeat;
        font-family: Arial, Tahoma, sans-serif;
      }

      .container-fluid {
        padding: 0 !important;
        margin: 0 !important;
      }


      /* =====================================================
         المؤقت
         ===================================================== */

      .timer-container {
        position: absolute;
        left: 50%;
        top: 29%;

        transform: translate(-50%, -50%);

        width: 500px;
        height: 145px;

        display: flex;
        align-items: center;
        justify-content: center;

        z-index: 20;

        pointer-events: none;
      }


      .timer {
        font-size: 92px;
        font-weight: bold;

        color: white;

        letter-spacing: 3px;

        text-shadow:
          0 0 8px #00eaff,
          0 0 18px #00eaff,
          0 0 30px #00eaff;
      }


      /* =====================================================
         آخر 10 ثوان
         ===================================================== */

      .danger-timer {

        color: #ff3030 !important;

        text-shadow:
          0 0 10px red,
          0 0 20px red,
          0 0 35px red !important;

        animation:
          dangerPulse 0.45s infinite alternate;
      }


      @keyframes dangerPulse {

        from {
          transform: scale(1);
        }

        to {
          transform: scale(1.08);
        }

      }


      /* =====================================================
         أزرار التحكم
         ===================================================== */

      .control-area {

        position: absolute;

        top: 45%;

        left: 50%;

        transform: translateX(-50%);

        display: flex;

        justify-content: center;

        align-items: center;

        gap: 7px;

        z-index: 30;
      }


      .control-btn {

        width: 125px;
        height: 46px;

        border-radius: 11px;

        border: 2px solid white;

        color: white;

        font-size: 16px;

        font-weight: bold;

        box-shadow:
          0 3px 8px rgba(0,0,0,0.35);

        cursor: pointer;

        padding: 0;
      }


      .start {
        background: #18c637;
      }


      .pause {
        background: #f5a000;
      }


      .reset {
        background: #873be8;
      }


      .control-btn:hover {
        transform: scale(1.04);
      }


      /* =====================================================
         اختيار المدة
         ===================================================== */

      .duration-area {

        position: absolute;

        left: 50%;

        top: 54%;

        transform: translateX(-50%);

        text-align: center;

        z-index: 40;
      }


      .duration-title {

        font-size: 18px;

        font-weight: bold;

        color: white;

        text-shadow:
          0 2px 5px black;

        margin-bottom: 4px;
      }


      .duration-buttons {

        display: flex;

        justify-content: center;

        align-items: center;

        gap: 5px;
      }


      .duration-btn {

        width: 76px;
        height: 38px;

        border-radius: 10px;

        border: 2px solid white;

        background: #1268a8;

        color: white;

        font-size: 14px;

        font-weight: bold;

        cursor: pointer;

        padding: 0;

        box-shadow:
          0 3px 7px rgba(0,0,0,0.3);
      }


      .duration-btn:hover {
        background: #1787d0;
      }


      .selected-time {

        margin-top: 3px;

        font-size: 14px;

        font-weight: bold;

        color: white;

        text-shadow:
          0 2px 5px black;
      }


      /* =====================================================
         🚨 رسالة انتهاء الوقت
         ===================================================== */

      #finished-message {

        display: none;

        position: absolute;

        left: 50%;

        top: 38%;

        transform:
          translate(-50%, -50%);

        z-index: 100;

        background:
          rgba(190, 0, 0, 0.97);

        color: white;

        padding:
          22px 55px;

        border-radius: 22px;

        border: 4px solid white;

        text-align: center;

        font-size: 40px;

        font-weight: bold;

        box-shadow:
          0 0 45px rgba(255,0,0,0.9);

        animation:
          finishPulse
          0.65s infinite alternate;
      }


      @keyframes finishPulse {

        from {

          transform:
            translate(-50%, -50%)
            scale(1);

        }

        to {

          transform:
            translate(-50%, -50%)
            scale(1.08);

        }

      }


      /* =====================================================
         الشاشات الأصغر
         ===================================================== */

      @media (max-width: 1000px) {

        .timer-container {
          width: 420px;
        }

        .timer {
          font-size: 75px;
        }

        .control-btn {

          width: 110px;

          height: 42px;

          font-size: 14px;
        }

        .duration-btn {

          width: 70px;

          height: 36px;

          font-size: 13px;
        }

      }

    ")),
    
    
    # =======================================================
    # JavaScript - نظام الصوت
    # =======================================================
    
    tags$script(HTML("

      let audioContext = null;

      let soundRunning = false;

      let lastSecond = -1;

      let alarmPlayed = false;


      /* =====================================================
         تشغيل نظام الصوت
         ===================================================== */

      function startAudio() {

        if (!audioContext) {

          audioContext =
            new (
              window.AudioContext ||
              window.webkitAudioContext
            )();

        }

        if (
          audioContext.state === 'suspended'
        ) {

          audioContext.resume();

        }

      }


      /* =====================================================
         صوت التك العادي
         ===================================================== */

      function tickSound(
        frequency,
        duration
      ) {

        if (!audioContext)
          return;


        const oscillator =
          audioContext.createOscillator();


        const gain =
          audioContext.createGain();


        oscillator.type =
          'sine';


        oscillator.frequency.value =
          frequency;


        gain.gain.setValueAtTime(
          0.0001,
          audioContext.currentTime
        );


        gain.gain.exponentialRampToValueAtTime(
          0.20,
          audioContext.currentTime + 0.01
        );


        gain.gain.exponentialRampToValueAtTime(
          0.0001,
          audioContext.currentTime + duration
        );


        oscillator.connect(gain);

        gain.connect(
          audioContext.destination
        );


        oscillator.start();


        oscillator.stop(
          audioContext.currentTime +
          duration
        );

      }


      /* =====================================================
         🚨 صوت النهاية القوي جدًا
         ===================================================== */

      function strongAlarmSound(
        frequency,
        duration
      ) {

        if (!audioContext)
          return;


        const oscillator =
          audioContext.createOscillator();


        const gain =
          audioContext.createGain();


        /*
           square يعطي صوتًا أكثر حدة
           ووضوحًا من صوت التك العادي
        */

        oscillator.type =
          'square';


        oscillator.frequency.value =
          frequency;


        gain.gain.setValueAtTime(
          0.0001,
          audioContext.currentTime
        );


        gain.gain.exponentialRampToValueAtTime(
          0.55,
          audioContext.currentTime + 0.015
        );


        gain.gain.exponentialRampToValueAtTime(
          0.0001,
          audioContext.currentTime + duration
        );


        oscillator.connect(gain);


        gain.connect(
          audioContext.destination
        );


        oscillator.start();


        oscillator.stop(
          audioContext.currentTime +
          duration
        );

      }


      /* =====================================================
         🚨🚨 المنبه النهائي
         ===================================================== */

      function finalAlarm() {

        if (!audioContext)
          return;


        /*
           سلسلة قوية متتابعة
        */

        const alarm = [

          [700, 0],

          [1100, 250],

          [700, 500],

          [1100, 750],

          [700, 1000],

          [1100, 1250],

          [700, 1500],

          [1200, 1750],

          [700, 2050],

          [1200, 2300]

        ];


        alarm.forEach(
          function(note) {

            setTimeout(
              function() {

                strongAlarmSound(
                  note[0],
                  0.22
                );

              },
              note[1]
            );

          }
        );


        /*
           تكرار إنذار قصير بعد المجموعة الأولى
        */

        setTimeout(
          function() {

            strongAlarmSound(
              1000,
              0.40
            );

          },
          2800
        );


        setTimeout(
          function() {

            strongAlarmSound(
              750,
              0.40
            );

          },
          3300
        );


        setTimeout(
          function() {

            strongAlarmSound(
              1200,
              0.50
            );

          },
          3800
        );

      }


      /* =====================================================
         إظهار رسالة النهاية
         ===================================================== */

      function showFinishedMessage() {

        const message =
          document.getElementById(
            'finished-message'
          );


        if (message) {

          message.style.display =
            'block';

        }

      }


      /* =====================================================
         إخفاء رسالة النهاية
         ===================================================== */

      function hideFinishedMessage() {

        const message =
          document.getElementById(
            'finished-message'
          );


        if (message) {

          message.style.display =
            'none';

        }

      }


      /* =====================================================
         مراقبة المؤقت
         ===================================================== */

      function checkTimer() {

        const timer =
          document.getElementById(
            'timer'
          );


        if (!timer)
          return;


        const text =
          timer.innerText.trim();


        if (
          !/^\\d{2}:\\d{2}$/.test(text)
        ) {

          return;

        }


        const parts =
          text.split(':');


        const minutes =
          parseInt(parts[0]);


        const seconds =
          parseInt(parts[1]);


        const totalSeconds =
          minutes * 60 + seconds;


        /* =================================================
           🚨 انتهى الوقت
           ================================================= */

        if (
          totalSeconds === 0
        ) {

          showFinishedMessage();


          if (
            !alarmPlayed &&
            soundRunning
          ) {

            alarmPlayed =
              true;

            finalAlarm();

          }


          return;

        }


        hideFinishedMessage();


        alarmPlayed =
          false;


        /* =================================================
           آخر 10 ثوان
           ================================================= */

        if (
          totalSeconds <= 10
        ) {

          timer.classList.add(
            'danger-timer'
          );

        }

        else {

          timer.classList.remove(
            'danger-timer'
          );

        }


        /* =================================================
           منع تكرار الصوت
           ================================================= */

        if (
          seconds === lastSecond
        ) {

          return;

        }


        lastSecond =
          seconds;


        if (!soundRunning)
          return;


        /* =================================================
           أكثر من 30 ثانية
           ================================================= */

        if (
          totalSeconds > 30
        ) {

          tickSound(
            650,
            0.08
          );

        }


        /* =================================================
           من 30 إلى 11 ثانية
           ================================================= */

        else if (
          totalSeconds > 10
        ) {

          tickSound(
            900,
            0.12
          );


          setTimeout(
            function() {

              tickSound(
                700,
                0.08
              );

            },
            120
          );

        }


        /* =================================================
           آخر 10 ثوان
           ================================================= */

        else {

          tickSound(
            1200,
            0.15
          );


          setTimeout(
            function() {

              tickSound(
                1500,
                0.12
              );

            },
            180
          );

        }

      }


      /* =====================================================
         زر ابدأ
         ===================================================== */

      document.addEventListener(
        'click',
        function(event) {

          const target =
            event.target.closest(
              '#start'
            );


          if (target) {

            startAudio();

            soundRunning =
              true;

            alarmPlayed =
              false;

            hideFinishedMessage();

          }

        }
      );


      /* =====================================================
         زر إيقاف مؤقت
         ===================================================== */

      document.addEventListener(
        'click',
        function(event) {

          const target =
            event.target.closest(
              '#pause'
            );


          if (target) {

            soundRunning =
              false;

          }

        }
      );


      /* =====================================================
         زر إعادة
         ===================================================== */

      document.addEventListener(
        'click',
        function(event) {

          const target =
            event.target.closest(
              '#reset'
            );


          if (target) {

            soundRunning =
              false;

            alarmPlayed =
              false;

            lastSecond =
              -1;

            hideFinishedMessage();

          }

        }
      );


      /* =====================================================
         فحص المؤقت
         ===================================================== */

      setInterval(
        checkTimer,
        100
      );

    "))
    
  ),
  
  
  # =========================================================
  # المؤقت الحقيقي
  # =========================================================
  
  div(
    class = "timer-container",
    
    div(
      id = "timer",
      
      class = "timer",
      
      textOutput(
        "timer"
      )
      
    )
    
  ),
  
  
  # =========================================================
  # رسالة انتهاء الوقت
  # =========================================================
  
  div(
    id = "finished-message",
    
    "🚨 انتهى الوقت!"
    
  ),
  
  
  # =========================================================
  # أزرار التحكم
  # =========================================================
  
  div(
    class = "control-area",
    
    actionButton(
      "start",
      
      "▶ ابدأ",
      
      class =
        "control-btn start"
    ),
    
    
    actionButton(
      "pause",
      
      "Ⅱ إيقاف مؤقت",
      
      class =
        "control-btn pause"
    ),
    
    
    actionButton(
      "reset",
      
      "⟳ إعادة",
      
      class =
        "control-btn reset"
    )
    
  ),
  
  
  # =========================================================
  # اختيار مدة التحدي
  # =========================================================
  
  div(
    class = "duration-area",
    
    
    div(
      class = "duration-title",
      
      "⏱️ اختر مدة التحدي"
      
    ),
    
    
    div(
      class = "duration-buttons",
      
      
      actionButton(
        "min1",
        
        "1 دقيقة",
        
        class =
          "duration-btn"
      ),
      
      
      actionButton(
        "min2",
        
        "2 دقيقة",
        
        class =
          "duration-btn"
      ),
      
      
      actionButton(
        "min3",
        
        "3 دقائق",
        
        class =
          "duration-btn"
      ),
      
      
      actionButton(
        "min5",
        
        "5 دقائق",
        
        class =
          "duration-btn"
      )
      
    ),
    
    
    div(
      class = "selected-time",
      
      textOutput(
        "selected"
      )
      
    )
    
  )
  
)


# ===========================================================
# SERVER
# ===========================================================

server <- function(
    input,
    output,
    session
) {
  
  
  # =========================================================
  # المدة المختارة
  # =========================================================
  
  selected_minutes <-
    reactiveVal(5)
  
  
  # =========================================================
  # الوقت المتبقي
  # =========================================================
  
  remaining <-
    reactiveVal(
      5 * 60
    )
  
  
  # =========================================================
  # حالة المؤقت
  # =========================================================
  
  running <-
    reactiveVal(FALSE)
  
  
  # =========================================================
  # 1 دقيقة
  # =========================================================
  
  observeEvent(
    input$min1,
    {
      
      running(FALSE)
      
      selected_minutes(1)
      
      remaining(60)
      
    }
  )
  
  
  # =========================================================
  # 2 دقيقة
  # =========================================================
  
  observeEvent(
    input$min2,
    {
      
      running(FALSE)
      
      selected_minutes(2)
      
      remaining(120)
      
    }
  )
  
  
  # =========================================================
  # 3 دقائق
  # =========================================================
  
  observeEvent(
    input$min3,
    {
      
      running(FALSE)
      
      selected_minutes(3)
      
      remaining(180)
      
    }
  )
  
  
  # =========================================================
  # 5 دقائق
  # =========================================================
  
  observeEvent(
    input$min5,
    {
      
      running(FALSE)
      
      selected_minutes(5)
      
      remaining(300)
      
    }
  )
  
  
  # =========================================================
  # ابدأ
  # =========================================================
  
  observeEvent(
    input$start,
    {
      
      if (
        remaining() > 0
      ) {
        
        running(TRUE)
        
      }
      
    }
  )
  
  
  # =========================================================
  # توقف مؤقت
  # =========================================================
  
  observeEvent(
    input$pause,
    {
      
      running(FALSE)
      
    }
  )
  
  
  # =========================================================
  # إعادة
  # =========================================================
  
  observeEvent(
    input$reset,
    {
      
      running(FALSE)
      
      remaining(
        selected_minutes() * 60
      )
      
    }
  )
  
  
  # =========================================================
  # العد التنازلي
  # =========================================================
  
  observe({
    
    invalidateLater(
      1000,
      session
    )
    
    
    if (
      
      isolate(running()) &&
      
      isolate(remaining()) > 0
      
    ) {
      
      isolate({
        
        remaining(
          remaining() - 1
        )
        
      })
      
    }
    
    
    if (
      isolate(remaining()) <= 0
    ) {
      
      running(FALSE)
      
    }
    
  })
  
  
  # =========================================================
  # عرض المؤقت
  # =========================================================
  
  output$timer <-
    renderText({
      
      seconds <-
        remaining()
      
      
      minutes <-
        floor(
          seconds / 60
        )
      
      
      secs <-
        seconds %% 60
      
      
      sprintf(
        "%02d:%02d",
        
        minutes,
        
        secs
        
      )
      
    })
  
  
  # =========================================================
  # عرض المدة المختارة
  # =========================================================
  
  output$selected <-
    renderText({
      
      paste(
        "المدة المختارة:",
        selected_minutes(),
        "دقيقة"
      )
      
    })
  
}


# ===========================================================
# تشغيل التطبيق
# ===========================================================

shinyApp(
  ui,
  server
)

