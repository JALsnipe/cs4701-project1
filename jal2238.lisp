;CS4701 - Artificial Intelligence
;Jonathan Voris
;Project 1 - Pattern Matcher in Common Lisp

;Josh Lieberman
;jal2238

(defun matcher (list1 list2 c) ;defun, main function
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
         ((and (and (equal (listp a) nil) (listp b)) (not (equal (elt (symbol-name a) 0) #\?))) nil) ;handling nested lists
         ((and (equal (listp b) nil) (and (listp a) (not (equal (car a) '&)))) nil)
         ((numberp a) (if (equal a b)(if (null c) (matcher (cdr list1) (cdr list2) c) c))) ;test to make sure numbers work as well as symbols
         ((and (listp a) (equal (car a) '&))
          (if (amp (cdr a) b c)
              (matcher (cdr list1) (cdr list2) c)
            nil))
         
         ((and (listp a) (listp b)) ;if, evaluate the first thing in the list - are a and b lists?
               (and (matcher a b c) ;recursive call on a and b
                    (matcher (cdr list1) (cdr list2) c))) ;recursive call on the cdr (tail) of a and b, passing on c as it is needed later

              ((equal a '*) ;is a a '*'?
               (cond 
                ((equal (matcher (cdr list1) list2 c) nil) (matcher list1 (cdr list2) c)) ;if one is nil return the other
                ((equal (matcher list1 (cdr list2) c) nil) (matcher (cdr list1) list2 c)) ;if one is nil return the other
                ((and (equal (matcher (cdr list1) list2 c) t) (equal (matcher list1 (cdr list2) c) t)) t) ;if both are t return t
                ((and (listp (matcher (cdr list1) list2 c)) (listp (matcher list1 (cdr list2) c))) (cons (matcher list1 (cdr list2) c) (cons (matcher (cdr list1) list2 c) '()))); if both are pairs reutrn both pairs
                ((and (equal (matcher (cdr list1) list2 c) t) (listp (matcher list1 (cdr list2) c)) )(matcher list1 (cdr list2) c)) ;if one is t and one is a list (pairs), return the pairs
                ((and (equal (matcher list1 (cdr list2) c) t) (listp (listp (matcher (cdr list1) list2 c)))) (matcher (cdr list1) list2 c)) ;if one is t and one is a list (pairs), return the pairs
               ))
              
              ;start ?
              ((and (equal (elt (symbol-name a) 0) #\?) (> (length (symbol-name a)) 1)) ;is the first character of the element a '?' and is the element longer than one character?
               (if (assoc a c) ;if the variable is already assigned
                   (if (equal (cdr (assoc a c)) b) ;check if it's the same value
                       (matcher (cdr list1) (cdr list2) c) ;if so, continue
                     nil) ;if not, return nil
                 (matcher (cdr list1) (cdr list2) (cons (cons a b) c)))) ;add the variable values to list c
              ;end ?

              ;start ! 
              ((and (equal (elt (symbol-name a) 0) #\!) (> (length (symbol-name a)) 1)) ;! check
               (setf a (intern (concatenate 'string "?" (subseq (symbol-name a) 1)))) ;need to set the new ? constrcut to a, and use intern to convert a string to a symbol
               (if (assoc a c) ;if the variable is already assigned
                   (if (equal (cdr (assoc a c)) b) ;check if it's the same value
                       nil ;if so, return nil
                     (matcher (cdr list1) (cdr list2) c)))) ;pass c and continue
              ;end !

              ;start <
              ((and (equal (elt (symbol-name a) 0) #\<) (> (length (symbol-name a)) 1)) ;< check
               (setf a (intern (concatenate 'string "?" (subseq (symbol-name a) 1)))) ;need to set the new ? constrcut to a, and use intern to convert a string to a symbol
               (if (assoc a c) ;if the variable is already assigned
                   (if (< b (cdr (assoc a c))) ;is the current value stored in c less than our variable in the pattern that called '<'?
                       (matcher (cdr list1) (cdr list2) c) ;if yes, continue
                    nil))) ;else, return nil
              ;end <

              ;start >
              ((and (equal (elt (symbol-name a) 0) #\>) (> (length (symbol-name a)) 1)) ; > check
               (setf a (intern (concatenate 'string "?" (subseq (symbol-name a) 1)))) ;need to set the new ? constrcut to a, and use intern to convert a string to a symbol
               (if (assoc a c) ;if the variable is already assigned
                   (if (> b (cdr (assoc a c))) ;is the current value stored in c less than our variable in the pattern that called '>'?
                       (matcher (cdr list1) (cdr list2) c) ;if yes, continue
                    nil))) ;else, return nil
              ;end >

              (
               (or (equal a b) (equal a '?)) ; are a and b equal or is a a '?'
                    (matcher (cdr list1) (cdr list2) c)) ;recursive call
              (t nil)))))
  ) ;end matcher

(defun match (list1 list2) ;entry function
  (matcher list1 list2 nil)) ;we need to initialize c (association list) to nil

(defun amp (list1 list2 c) ;function to just handle input with &
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
) ;end amp