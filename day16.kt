package quick.start

enum class Op(val i: Int) {
  Sum(0),
  Prod(1),
  Min(2),
  Max(3),
  Lit(4),
  Gt(5),
  Lt(6),
  Eq(7);
  companion object {
    fun fromInt(i: Int) = Op.values().first { it.i == i }
  }
}

class Packet(version: Int, op: Op, lit: Long, children: List<Packet>) {
  val version = version
  val op = op
  val children = children
  val lit = lit

  // literal
  constructor(v: Int, l: Long) : this(v, Op.Lit, l, emptyList()) {}
  // recursive
  constructor(v: Int, op: Op, ch: List<Packet>) : this(v, op, 0, ch) {}

  fun versionTotal(): Int {
    return version + children.map { it.versionTotal() }.sum()
  }
  fun eval(): Long {
    if (this.op == Op.Lit) return this.lit

    val res = children.map { it.eval() }
    if (op == Op.Sum) return res.sum()
    if (op == Op.Prod) return res.reduce(Long::times)
    if (op == Op.Min) return res.minOrNull()!!
    if (op == Op.Max) return res.maxOrNull()!!

    val (lhs, rhs) = res
    var cond = false
    if (op == Op.Gt) cond = lhs > rhs
    if (op == Op.Lt) cond = lhs < rhs
    if (op == Op.Eq) cond = lhs == rhs
    return if (cond) 1 else 0
  }
}

fun parseLit(s: String): Pair<Long, String> {
  var s = s
  var res = 0L
  var done = false
  while (!done) {
    res = res * 16 + s.substring(1, 5).toLong(2)
    done = s[0] == '0'
    s = s.substring(5)
  }
  return Pair(res, s)
}

fun parsePacket(s: String): Pair<Packet, String> {
  val v = s.substring(0, 3).toInt(2)
  val ty = Op.fromInt(s.substring(3, 6).toInt(2))
  val s = s.substring(6)
  if (ty == Op.Lit) {
    val (l, s) = parseLit(s)
    return Pair(Packet(v, l), s)
  }
  if (s[0] == '0') { // length of packets
    val len = s.substring(1, 16).toInt(2)
    val ss = s.substring(16 + len)
    var s = s.substring(16, 16 + len)
    var ps = mutableListOf<Packet>()
    while (!s.isEmpty()) {
      val (p, ss) = parsePacket(s)
      s = ss
      ps.add(p)
    }
    return Pair(Packet(v, ty, ps), ss)
  } else { // num. packets
    val num = s.substring(1, 12).toInt(2)
    var s = s.substring(12)
    var ps = mutableListOf<Packet>()
    for (i in 1..num) {
      val (p, ss) = parsePacket(s)
      s = ss
      ps.add(p)
    }
    return Pair(Packet(v, ty, ps), s)
  }
}

fun parseFull(s: String): Packet {
  val (p, s) = parsePacket(s)
  assert(s.all { it == '0' })
  return p
}

fun main() {
  val inp = readLine()!!
  val data = ('1' + inp).toBigInteger(16).toString(2).drop(1)
  val packet = parseFull(data)
  println(packet.versionTotal())
  println(packet.eval())
}
