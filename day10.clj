;;; common logic
(defn flip [c]
  (case c
    \) \(
    \] \[
    \} \{
    \> \<
    nil))
(defn open? [c] (nil? (flip c)))

(defn compile-code [code]
  (loop [cs code
         stack ()]
    (let [c (first cs)
          cs' (rest cs)]
      (cond
        (empty? cs) stack
        (open? c) (recur cs' (cons c stack))
        (= (flip c) (first stack)) (recur cs' (rest stack))
        :else c))))

;;; Part 1
(def syntax-error-score
  #(case %
    \) 3
    \] 57
    \} 1197
    \> 25137
    0))
(def compute-part1 #(apply + (map syntax-error-score (filter char? %))))

;;; Part 2
(def ac-cost
  #(case %
     \( 1
     \[ 2
     \{ 3
     \< 4
     0))
(defn autocomplete-score [stk] (reduce #(+ (* 5 %1) %2) (map ac-cost stk)))

(def median #(nth (sort %) (int (/ (count %) 2))))
(def compute-part2 #(median (map autocomplete-score (filter seq? %))))

;;; input
(def lines
  (loop [res ()]
    (let [line (read-line)]
      (if (nil? line)
        res
        (recur (cons line res))))))
(def results (map compile-code lines))

;;; output
(println (compute-part1 results) (compute-part2 results))
