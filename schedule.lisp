(defpackage #:shibuyarakugo-parser/schedule
  (:use #:cl
        #:shibuyarakugo-parser/utils
        #:lquery)
  (:import-from #:quri)
  (:import-from #:cl-ppcre)
  (:export #:parse-index))
(in-package #:shibuyarakugo-parser/schedule)

(defvar *base-uri*
  (quri:uri "https://eurolive.jp/shibuya-rakugo/"))

(defun parse-performers (performers)
  (mapcar (lambda (performer)
            (ppcre:regex-replace "\\*+$" performer ""))
          (remove ""
                  (ppcre:split "　" performers)
                  :test 'equal)))

(defun parse-dl (dl)
  (let ((dt ($1 dl "dt")))
    (assert dt)
    (let ((date ($1 dt (render-text))))
      (or (ppcre:register-groups-bind ((#'parse-integer month day))
              ("^(\\d{1,2})月(\\d{1,2})日" date)
            (let* ((year (get-year-of-month month))
                   (date-string (format nil "~D-~2,'0D-~2,'0D" year month day)))
              (coerce
               ($ dl "dd"
                 (combine ".time" ".title" ".text")
                 (map-apply (lambda (time title text)
                              (let ((time-string ($1 time (render-text))))
                                (or (ppcre:register-groups-bind (start-time end-time)
                                        ("^(\\d{2}:\\d{2})～(\\d{2}:\\d{2})$" time-string)
                                      `(("date" . ,date-string)
                                        ("start-time" . ,start-time)
                                        ("end-time" . ,end-time)
                                        ("title" . ,(ppcre:regex-replace "「(.+)」" ($1 title (render-text)) "\\1"))
                                        ("performers" . ,(parse-performers ($1 text (render-text))))))
                                    (error "Invalid shibuya-rakugo time: ~S" time-string))))))
               'list)))
          (error "Invalid shibuya-rakugo date: ~S" date)))))

(defun parse-index (body)
  (let* ((main ($1 (initialize body) "#schedule"))
         (schedules ($ main ".calendar dl")))
    (assert main)
    (assert (< 0 (length schedules)))
    `(("schedules" . ,(loop for schedule across schedules
                            append (parse-dl schedule))))))
