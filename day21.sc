// part 1
def playPractice(a: Int, sa: Int, b: Int, sb: Int, d: Int, it: Int) : Int =
  val a_ = (a + 3 * d + 3) % 10
  val sa_ = sa + a_ + 1
  val it_ = it + 3
  if sa_ >= 1000 then
    return sb * it_
  else
    return playPractice(b, sb, a_, sa_, (d + 3) % 10, it_)

def scorePractice(a: Int, b: Int) : Int = playPractice(a - 1, 0, b - 1, 0, 1, 0)

// part 2
var dpa = Array.ofDim[Long](10, 10, 21, 21)
var dpb = Array.ofDim[Long](10, 10, 21, 21)
def get(a: Int, sa: Int, b: Int, sb: Int) : (Long, Long) =
  var wa = dpa(a)(b)(sa)(sb)
  var wb = dpb(a)(b)(sa)(sb)
  if wa + wb != 0 then return (wa, wb)
  for i <- 1 to 3
      j <- 1 to 3
      k <- 1 to 3 do
    val a_ = (a + i + j + k) % 10
    val sa_ = sa + a_ + 1
    if sa_ >= 21 then
      wa += 1
    else
      val (wb_, wa_) = get(b, sb, a_, sa_)
      wa += wa_
      wb += wb_
  dpa(a)(b)(sa)(sb) = wa
  dpb(a)(b)(sa)(sb) = wb
  (wa, wb)

def scoreQuantum(a: Int, b: Int) : Long =
  val (wa, wb) = get(a - 1, 0, b - 1, 0)
  wa.max(wb)

// I/O
def readPos() : Int =
  scala.io.StdIn.readf1("Player {1} starting position: {0,number}")
    .asInstanceOf[Long].toInt

@main def day21 =
  val a = readPos()
  val b = readPos()
  println(s"${scorePractice(a, b)} ${scoreQuantum(a, b)}")
