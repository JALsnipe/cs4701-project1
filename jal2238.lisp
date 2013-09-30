;this only works for for pairs like this:
;CL-USER 10 : 4 > (match '(?x ?y c) '(a b c))
;((?Y . B) (?X . A))
;never mind, i thought we were required to have number support for the matcher
;number support added
;< WIP (TODO) - done
;not done: >, & - now done
;everything done except for the star operation on line 6, need to handle returning bindings

(defun comp-q2 (list1 list2 c) ;defun
  (cond ;if
   ((and (null list1) (not (null list2))) nil)
   ((and (equal (car list1) '*) (equal list2  nil)) (if (not (equal (cdr list1) nil)) nil (if (listp c) c t))) ;if you have bindings return bindings, else return t.  fixed to include case where if a star is matched with () and there are still more elements in list1, return nil.
   ((and (null list2) (not (null list1))) nil) ;check if the pattern (list1) is a * (see above)
   ((and (null list1) (null list2))
    (if (not (null c)) ;if we have bindings in c, retun the bindings.  otherwise return t.
      c ;return c
      t)) ;return t
   (t ;else
    (let ((a (car list1)) (b (car list2))) ;a is the car of list1 and b is the car of list2
        (cond 
         ((numberp a) (if (equal a b)(if (null c) (comp-q2 (cdr list1) (cdr list2) c) c))) ;test to make sure numbers work as well as symbols
         ((and (listp a) (equal (car a) '&))
         ; (and (comp-q2 (cdr list1) (cdr list2) c)
          (if (amp (cdr a) b c)
              (comp-q2 (cdr list1) (cdr list2) c)
            nil))
              
         ((and (listp a) (listp b)) ;if, evaluate the first thing in the list - are a and b lists?
               (and (comp-q2 a b c) ;recursive call on a and b
                    (comp-q2 (cdr list1) (cdr list2) c))) ;recursive call on the cdr (tail) of a and b, passing on c as it is needed later
              ((equal a '*) ;is a a '*'
             ;1;(or 
              ; (comp-q2 (cdr list1) list2 c) ;increment list1 but not list2
              ; (comp-q2 list1 (cdr list2) c))) ;increment list2 but not list1 ;THERE MAY BE MULTIPLE SOLUTIONS IN THIS FUNCTION.  WE NEED TO FIND THEM ALL
              ;1;(cons (comp-q2 (cdr list1) list2 c) c) ;increment list1 but not list2
               ;1;(cons (comp-q2 list1 (cdr list2) c) c))
              ; (if (and (listp (comp-q2 (cdr list1) list2 c)) (listp (comp-q2 list1 (cdr list2) c)))
                  ; (cons (cons (comp-q2 (cdr list1) list2 c) c) (cons (comp-q2 list1 (cdr list2) c) c))
                ; nil)
               (cond 
                ((equal (comp-q2 (cdr list1) list2 c) nil) (comp-q2 list1 (cdr list2) c)) ;if one is nil return the other
                ((equal (comp-q2 list1 (cdr list2) c) nil) (comp-q2 (cdr list1) list2 c)) ;if one is nil return the other
                ((and (equal (comp-q2 (cdr list1) list2 c) t) (equal (comp-q2 list1 (cdr list2) c) t)) t) ;if both are t return t
                ((and (listp (comp-q2 (cdr list1) list2 c)) (listp (comp-q2 list1 (cdr list2) c))) (cons (comp-q2 list1 (cdr list2) c) (cons (comp-q2 (cdr list1) list2 c) '()))); if both are pairs reutrn both pairs
                ((and (equal (comp-q2 (cdr list1) list2 c) t) (listp (comp-q2 list1 (cdr list2) c)) )(comp-q2 list1 (cdr list2) c)) ;if one is t and one is a list (pairs), return the pairs
                ((and (equal (comp-q2 list1 (cdr list2) c) t) (listp (listp (comp-q2 (cdr list1) list2 c)))) (comp-q2 (cdr list1) list2 c)) ;if one is t and one is a list (pairs), return the pairs
                ;((and (equal (comp-q2 (cdr list1) list2 c) nil) (listp (comp-q2 list1 (cdr list2) c))) (comp-q2 list1 (cdr list2) c)) ;if one is nil and the other is a pair, return the pair
                ;((and (equal (comp-q2 list1 (cdr list2) c) nil) (listp (comp-q2 (cdr list1) list2 c))) (comp-q2 (cdr list1) list2 c)) ;if one is nil and the other is a pair, return the pair
               ))
              ((and (equal (elt (symbol-name a) 0) #\?) (> (length (symbol-name a)) 1)) ;if we have a ? variable, wrap this into another function? (similar to ! and < >) convert ! and < > to ?
               (if (assoc a c) ;if the variable is already assigned
                   (if (equal (cdr (assoc a c)) b) ;check if it's the same value
                       (comp-q2 (cdr list1) (cdr list2) c) ;if so, continue
                     nil) ;if not, return nil
                 (comp-q2 (cdr list1) (cdr list2) (cons (cons a b) c)))) ;add the variable values to list c
              ((and (equal (elt (symbol-name a) 0) #\!) (> (length (symbol-name a)) 1))
               (setf a (intern (concatenate 'string "?" (subseq (symbol-name a) 1)))) ;need to set the new ? constrcut to a, and use intern to convert a string to a symbol
               (if (assoc a c) ;if the variable is already assigned
                   (if (equal (cdr (assoc a c)) b) ;check if it's the same value
                       nil ;if so, return nil
                     (comp-q2 (cdr list1) (cdr list2) c)))) ;pass c and continue
              ;start <
              ((and (equal (elt (symbol-name a) 0) #\<) (> (length (symbol-name a)) 1))
               (setf a (intern (concatenate 'string "?" (subseq (symbol-name a) 1)))) ;need to set the new ? constrcut to a, and use intern to convert a string to a symbol
               (if (assoc a c) ;if the variable is already assigned
                   (if (< b (cdr (assoc a c))) ;is the current value stored in c less than our variable in the pattern that called '<'?
                       (comp-q2 (cdr list1) (cdr list2) c) ;if yes, continue
                    nil))) ;else, return nil
              ;end <
              ;start >
              ((and (equal (elt (symbol-name a) 0) #\>) (> (length (symbol-name a)) 1))
               (setf a (intern (concatenate 'string "?" (subseq (symbol-name a) 1)))) ;need to set the new ? constrcut to a, and use intern to convert a string to a symbol
               (if (assoc a c) ;if the variable is already assigned
                   (if (> b (cdr (assoc a c))) ;is the current value stored in c less than our variable in the pattern that called '>'?
                       (comp-q2 (cdr list1) (cdr list2) c) ;if yes, continue
                    nil))) ;else, return nil
              ;end >
              (
               (or (equal a b) (equal a '?)) ; are a and b eqal or is a a '?'
                    (comp-q2 (cdr list1) (cdr list2) c)) ;recursive call
              (t nil))))))

(defun match (list1 list2) ;entry function
  (comp-q2 list1 list2 nil)) ;we need to initialize c to nil

(defun amp (list1 list2 c)
 
  (let ((a (car list1)))
    (cond
     ((null a) t)   
     ((and (equal (elt (symbol-name a) 0) #\?) (> (length (symbol-name a)) 1)) ;if we have a ? variable, wrap this into another function? (similar to ! and < >) convert ! and < > to ?

      (if (assoc a c) ;if the variable is already assigned
    ;    (print "here") nil)
        (if (equal (cdr (assoc a c)) list2) ;check if it's the same value
           (amp (cdr list1) list2 c) ;if so, continue
          nil) ;if not, return nil
      (amp (cdr list1) list2 (cons (cons a list2) c))))
   ((and (equal (elt (symbol-name a) 0) #\!) (> (length (symbol-name a)) 1))
    (setf a (intern (concatenate 'string "?" (subseq (symbol-name a) 1)))) ;need to set the new ? constrcut to a, and use intern to convert a string to a symbol
    (if (assoc a c) ;if the variable is already assigned
        (if (equal (cdr (assoc a c)) list2) ;check if it's the same value
            nil ;if so, return nil
          (amp (cdr list1) list2 c)))) ;pass c and continue
   ;start <
   ((and (equal (elt (symbol-name a) 0) #\<) (> (length (symbol-name a)) 1))
    (setf a (intern (concatenate 'string "?" (subseq (symbol-name a) 1)))) ;need to set the new ? constrcut to a, and use intern to convert a string to a symbol
    (if (assoc a c) ;if the variable is already assigned
        (if (< list2 (cdr (assoc a c))) ;is the current value stored in c less than our variable in the pattern that called '<'?
            (amp (cdr list1) list2 c) ;if yes, continue
          nil))) ;else, return nil
   ;end <
   ;start >
   ((and (equal (elt (symbol-name a) 0) #\>) (> (length (symbol-name a)) 1))
    (setf a (intern (concatenate 'string "?" (subseq (symbol-name a) 1)))) ;need to set the new ? constrcut to a, and use intern to convert a string to a symbol
    (if (assoc a c) ;if the variable is already assigned
        (if (> list2 (cdr (assoc a c))) ;is the current value stored in c less than our variable in the pattern that called '>'?
            (amp (cdr list1) list2 c) ;if yes, continue
          nil))) ;else, return nil
  ;end >
  
 (t nil)))
)