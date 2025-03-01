###
### randgen.janet
###
### Macros and utilties for executing psuedo probabalistic "random" code.
### The PRNG is a dynamic binding, allowing for easy deterministic execution
###

(defdyn *rng* "RNG used to generate random numbers")

(defn- get-rng
  ``
  Get RNG.

  If dynamic variable *rng* is non-nil, use that as RNG.
  Otherwise create a new RNG and set the dynamic variable
  *rng* to the newly created value.
  ``
  []
  (def rng (dyn *rng*))
  (if rng rng (setdyn *rng* (math/rng))))

(defn set-seed
  "Sets the RNG seed for execution"
  [seed]
  (setdyn *rng* (math/rng seed)))

(defn rand-uniform
  "Get a random number uniformly between 0 and 1"
  []
  (math/rng-uniform (get-rng)))

(defn rand-int
  "Get a random integer in a range [start, end) that is approximately uniformly distributed"
  [start end]
  (def diff (- end start))
  (+ start (math/floor (* diff (rand-uniform)))))

(defn rand-index
  "Get a random numeric index of an indexed data structure"
  [xs]
  (rand-int 0 (length xs)))

(defn rand-value
  "Get a random value of an indexed data structure"
  [xs]
  (get xs (rand-int 0 (length xs))))

(defn weights-to-cdf
  "Convert an array of weights to a discrete cdf that can be more efficiently used to
  take a weighted random choice"
  [weights]
  (def inv-total-weight (/ (sum weights)))
  (var cumsum 0)
  (seq [w :in weights]
    (+= cumsum w)
    (* cumsum inv-total-weight)))

(defn rand-cdf
  "Pick a random index, weighted by a discrete cumulative distribution function."
  [cdf]
  (def p (rand-uniform))
  (def l (length cdf))
  (var min-idx 0)
  (var max-idx l)
  (while (< min-idx max-idx)
    (def mid-idx (math/floor (* 0.5 (+ min-idx max-idx))))
    (def mid-p (get cdf mid-idx))
    (if (<= mid-p p)
      (set min-idx (+ 1 mid-idx))
      (set max-idx mid-idx)))
  min-idx)

(defn rand-weights
  "Pick a random index given a set of weights"
  [weights]
  (rand-cdf (weights-to-cdf weights)))

(defmacro rand-path
  "Execute one of the paths randomly with uniform distribution"
  [& paths]
  ~(case (,rand-int 0 ,(length paths))
     ,;(array/concat @[] ;(map tuple (range (length paths)) paths))))

(defmacro rand-cdf-path
  "Execute one of the paths randomly given a discrete distribution as a CDF"
  [cdf & paths]
  ~(case (,rand-cdf ,cdf)
     ,;(array/concat @[] ;(map tuple (range (length paths)) paths))))

(defmacro rand-weights-path
  "Execute one of the paths randomly given a discrete distribution as a set of weights"
  [weights & paths]
  ~(case (,rand-weights ,weights)
     ,;(array/concat @[] ;(map tuple (range (length paths)) paths))))

