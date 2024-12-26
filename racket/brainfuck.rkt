#lang racket

(define program (port->string (current-input-port)))

(let loop ([ip 0]
           [memory (make-bytes 30000 0)]
           [pointer 0]
           [stack null])
  (cond
    [(>= ip (string-length program)) (display "")]
    [(eq? (string-ref program ip) #\+)
     (bytes-set! memory pointer (modulo (+ (bytes-ref memory pointer) 1) 256))
     (loop (+ ip 1) memory pointer stack)]
    [(eq? (string-ref program ip) #\-)
     (bytes-set! memory pointer (modulo (- (bytes-ref memory pointer) 1) 256))
     (loop (+ ip 1) memory pointer stack)]
    [(eq? (string-ref program ip) #\<)
     (loop (+ ip 1) memory (modulo (- pointer 1) 30000) stack)]
    [(eq? (string-ref program ip) #\>)
     (loop (+ ip 1) memory (modulo (+ pointer 1) 30000) stack)]
    [(eq? (string-ref program ip) #\.)
     (display (integer->char (bytes-ref memory pointer)))
     (loop (+ ip 1) memory pointer stack)]
    [(eq? (string-ref program ip) #\,)
     (bytes-set! memory pointer (char->integer (read-char)))
     (loop (+ ip 1) memory pointer stack)]
    [(eq? (string-ref program ip) #\[)
     (if (zero? (bytes-ref memory pointer))
         (let search ([ip (+ ip 1)]
                      [depth 1])
           (cond
             [(zero? depth) (loop ip memory pointer stack)]
             [(>= ip (string-length program)) (error "unmatched '['")]
             [(eq? (string-ref program ip) #\[)
              (search (+ ip 1) (+ depth 1))]
             [(eq? (string-ref program ip) #\])
              (search (+ ip 1) (- depth 1))]
             [else (search (+ ip 1) depth)]))
         (loop (+ ip 1) memory pointer (cons ip stack)))]
    [(eq? (string-ref program ip) #\])
     (if (pair? stack)
         (loop (first stack) memory pointer (rest stack))
         (error "umatched ']'"))]
    [else (loop (+ ip 1) memory pointer stack)]))
