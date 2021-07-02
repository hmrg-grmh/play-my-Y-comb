
(((lambda (target)
    ((lambda (f) (f f))
        (lambda (f)
            (target
                (lambda (x) ((f f) x))))))
    (lambda (factorial)
            (lambda (x)
                (cond ((= x 1) 1)
                    (else (* x (factorial (- x 1)))))))) 6)
;


#| 中括号是静态的确定的值，后直接跟第一元素 |#
(
    (
        [lambda (koyuu)
            (
                [lambda (umareru)
                    (umareru umareru)
                ]
                
                [lambda (chiyo)
                    (
                        koyuu
                        
                        [lambda (pakomata)
                            ((chiyo chiyo) pakomata)
                        ]
                    )
                ]
            )
        ]
        
        [lambda (chiyonoma)
            [lambda (args)
                (record-case args
                    [(remb) (num rem)
                        (if (< num rem) num
                            (chiyonoma [list 'remb (- num rem) rem])
                            #| in '[remb (- num rem) rem] the (- num rem) will not cal |#
                        )
                    ]
                )
            ]
        ]
    )
    
    '[remb 3 2]
)



;;;;;;;;;;;;;;;;;;;;;;;;;;; tests in learning ...

;; rkt code:
([lambda (x)
    (match x
        [(list num rem)
            (- num rem)
        ]
    )
] '[4 3])

;; chez code:
([lambda (x)
    (record-case x
        [(args) (num rem)
            (- num rem)
        ]
    )
] '[args 4 3])


(
[lambda (args)
    (record-case args
        [(remb) (num rem)
            
            (if (< num rem) num
                rem
            )
        ]
    )
]  [list 'remb (- 33 32) 2])







