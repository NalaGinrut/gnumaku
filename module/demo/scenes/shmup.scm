(define-module (demo scenes shmup)
  #:use-module (oop goops)
  #:use-module (gnumaku core)
  #:use-module (gnumaku generics)
  #:use-module (gnumaku director)
  #:use-module (gnumaku scene)
  #:use-module (gnumaku keycodes)
  #:use-module (gnumaku coroutine)
  #:use-module (gnumaku bullet)
  #:use-module (gnumaku assets)
  #:use-module (gnumaku scene-graph)
  #:use-module (gnumaku path)
  #:use-module (demo level)
  #:use-module (demo actor)
  #:use-module (demo player)
  #:use-module (demo enemy)
  #:use-module (demo enemies)
  #:use-module (demo boss)
  #:use-module (demo hud)
  #:use-module (demo levels demo)
  #:duplicates (merge-generics)
  #:export (<shmup-scene>
            background
            field-width
            field-height
            player
            hud
            current-level))

(define (load-music)
  (load-asset "01-speedway.ogg"))

(define-class <shmup-scene> (<scene>)
  (background #:accessor background #:init-keyword #:background #:init-value #f)
  (field-width #:accessor field-width #:init-keyword #:field-width #:init-value 480)
  (field-height #:accessor field-height #:init-keyword #:field-height #:init-value 560)
  (player #:accessor player #:init-keyword #:player #:init-thunk make-player)
  (hud #:accessor hud #:init-keyword #:hud #:init-value #f)
  (player-sheet #:accessor player-sheet #:init-keyword #:player-sheet #:init-value #f)
  (enemy-sheet #:accessor enemy-sheet #:init-keyword #:enemy-sheet #:init-value #f)
  (shot-sound #:accessor shot-sound #:init-keyword #:shot-sound #:init-value #f)
  (music #:accessor music #:init-thunk load-music)
  (current-level #:accessor current-level #:init-keyword #:current-level #:init-value #f))

(define-method (draw (scene <shmup-scene>))
  (draw-image (background scene) 0 0)
  (draw (current-level scene))
  (draw-hud (hud scene)))

(define-method (update (scene <shmup-scene>))
  (update (current-level scene)))

(define-method (on-start (scene <shmup-scene>))
  (load-assets scene)
  (init-player scene)
  (set! (current-level scene) (make-demo-level (player scene)
                                               (field-width scene)
                                               (field-height scene)))
  (set! (hud scene) (make-hud (current-level scene) 800 600))
  (set! (position (current-level scene)) (make-vector2 20 20))
  (run (current-level scene))
  (play-audio-stream (music scene) 1 0 1 #t))

(define-method (load-assets (scene <shmup-scene>))
  (set! (background scene) (load-asset "background.png"))
  (set! (shot-sound scene) (load-asset "player_shot.wav")))

(define-method (init-player (scene <shmup-scene>))
  (let ((player (player scene)))
    (set! (shot player) (lambda (player) (player-shot-1 player)))
    (set! (shot-sound player) (shot-sound scene))
    (set! (position player) (make-vector2 (/ (field-width scene) 2)
                                          (- (field-height scene) 32)))))

(define-coroutine (player-shot-1 player)
  (when (shooting player)
    (play-sample (shot-sound player) .8 0 1)
    (let* ((pos (position player))
           (speed 15)
           (bullets (bullet-system player))
           (type 'sword))
      (emit-bullet bullets (vector2-sub pos (make-vector2 16 0)) speed 269 type)
      (emit-bullet bullets (vector2-sub pos (make-vector2 0 20)) speed 270 type)
      (emit-bullet bullets (vector2-add pos (make-vector2 16 0)) speed 271 type))
    (wait player 3)
    (player-shot-1 player)))

(define-method (add-test-enemy (scene <shmup-scene>))
  (let ((enemy (make-enemy-1 (random (field-width scene)) (random 150))))
    (add-enemy (current-level scene) enemy)))

(define-method (add-test-enemy-2 (scene <shmup-scene>))
  (add-enemy (current-level scene)
             (make-enemy-2 (make-vector2 (/ (field-width scene) 2) 60))))

(define-method (add-boss (scene <shmup-scene>))
  (let ((boss (make-boss (/ (field-width scene) 2) 50)))
    (add-enemy (current-level scene) boss)))

(define-method (toggle-player-invincible (scene <shmup-scene>))
  (let ((player (player scene)))
    (set! (invincible player) (not (invincible player)))))

(define-method (clear-bullets (scene <shmup-scene>))
  (let ((system (enemy-bullet-system (current-level scene))))
    (clear-bullet-system system)))

(define-method (on-key-pressed (scene <shmup-scene>) key)
  (when (eq? key (keycode 'up))
    (set-movement (player scene) 'up #t))
  (when (eq? key (keycode 'down))
    (set-movement (player scene) 'down #t))
  (when (eq? key (keycode 'left))      
    (set-movement (player scene) 'left #t))
  (when (eq? key (keycode 'right))     
    (set-movement (player scene) 'right #t))
   (when (eq? key (keycode 'z))
     (set! (shooting (player scene)) #t)))

(define-method (on-key-released (scene <shmup-scene>) key)
  (when (eq? key (keycode 'escape))
    (director-pop-scene))
   (when (eq? key (keycode 'up))
     (set-movement (player scene) 'up #f))
   (when (eq? key (keycode 'down))      
     (set-movement (player scene) 'down #f))
   (when (eq? key (keycode 'left))      
     (set-movement (player scene) 'left #f))
   (when (eq? key (keycode 'right))     
     (set-movement (player scene) 'right #f))
   (when (eq? key (keycode 'z))
     (set! (shooting (player scene)) #f))
   (when (eq? key (keycode 'w))
     (clear-enemies (current-level scene)))
   (when (eq? key (keycode 'q))
     (add-test-enemy scene))
   (when (eq? key (keycode 'e))
     (add-test-enemy-2 scene))
   (when (eq? key (keycode 't))
     (toggle-player-invincible scene))
   (when (eq? key (keycode 'c))
     (clear-bullets scene))
   (when (eq? key (keycode 'b))
     (add-boss scene)))
