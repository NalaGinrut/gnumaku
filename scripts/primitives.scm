(define pi 3.141592654)

(define (deg2rad angle)
  (* angle (/ pi 180)))

(define (cos-deg angle)
  (cos (deg2rad angle)))

(define (sin-deg angle)
  (sin (deg2rad angle)))

(define (emit-bullet system x y speed direction acceleration angular-velocity type)
  (let ((bullet (make-bullet system)))
    (set-bullet-type! bullet type)
    (set-bullet-position! bullet x y)
    (set-bullet-speed! bullet speed)
    (set-bullet-direction! bullet direction)
    (set-bullet-acceleration! bullet acceleration)
    (set-bullet-angular-velocity! bullet angular-velocity)
    bullet))

(define (emit-circle system x y radius num-bullets rotate-offset speed acceleration angular-velocity type)
  (define bullets '())
  (let iterate ((i 0))
    (when (< i num-bullets)
      (let ((direction (+ rotate-offset (* i (/ 360 num-bullets)))))
	(let ((x (+ x (* radius (cos-deg direction))))
	      (y (+ y (* radius (sin-deg direction)))))
	  (set! bullets
		(cons (emit-bullet system x y speed direction acceleration angular-velocity type) bullets))
	  (iterate (1+ i))))))
  bullets)
