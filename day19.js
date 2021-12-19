const data = require('fs').readFileSync(require('process').argv[2], encoding='utf8').trim()
var scanners = data.split('\n\n')
  .map(s => s.split('\n').slice(1)
    .map(p => p.split(',').map(x => parseInt(x))));

function permute(xs) {
  return !xs.length ? [[]] :
    xs.flatMap(x => permute(xs.filter(v => v!==x)).map(vs => [x, ...vs]));
}
const perms = permute([0,1,2]);
const signs = (function () {
  var res = [];
  for (var i = 0; i < 8; i++) {
    res.push([0,1,2].map(b => ((i >> b) & 1) ? -1 : 1));
  }
  return res;
})();

function transform(p, perm, sgn) {
  return [0,1,2].map(i => sgn[i] * p[perm[i]]);
}

function check(sa, sb, j) {
  for (const p of sb) {
    for (const pp of sa) {
      const c = p.map((x, i) => pp[i] - x);
      var matched = 0;
      for (const pt of sb) {
        const cur = pt.map((x, i) => x + c[i]).toString();
        if (fixedScanner[j].has(cur))
          matched++;
      }
      if (matched >= 12) return c;
    }
  }
}

function update(i, j) {
  for (const perm of perms) {
    for (const s of signs) {
      const cur = scanners[i].map(p => transform(p, perm, s));
      const res = check(scanners[j], cur, j);
      if (res) {
        scanners[i] = cur;
        offset[i] = res.map((x, ix) => x + offset[j][ix]);
        return true;
      }
    }
  }
  return false;
}

const N = scanners.length;
var done = [], offset = [];
var fixedScanner = [];
for (var i = 0; i < N; i++) {
  done.push(false);
  offset.push(undefined);
  fixedScanner.push(undefined);
}
var q = [0];
done[0] = true;
offset[0] = [0,0,0];
fixedScanner[0] = new Set(scanners[0].map(p => p.toString()));
while (q.length) {
  var j = q.pop();
  for (const i in scanners) {
    if (!done[i]) {
      if (update(i, j)) {
        done[i] = true;
        fixedScanner[i] = new Set(scanners[i].map(p => p.toString()));
        q.push(i);
      }
    }
  }
}

// part 1
var beacons = [];
for (const i in scanners) {
  beacons = beacons.concat(scanners[i].map(p => p.map((x, j) => x + offset[i][j])));
}
beacons = new Set(beacons.map(p => p.toString()));
console.log(beacons.size);

// part 2
function dist(a, b) {
  return a.map((x, i) => Math.abs(x - b[i])).reduce((u, v) => u + v);
}

var maxdist = 0;
for (const a of offset)
  for (const b of offset)
    maxdist = Math.max(maxdist, dist(a, b));
console.log(maxdist);
