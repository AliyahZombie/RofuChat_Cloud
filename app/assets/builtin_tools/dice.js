// RofuChat built-in tool: D&D / TRPG dice roller.
// Syntax (case-insensitive, several expressions separated by "," or ";"):
//   d20, 1d20+5, 2d6+1d4+3, (1d8+2)*2, d%, 4dF
//   4d6kh3 / 4d6k3 (keep highest), 2d20kl1 (keep lowest), 4d6dl1 (drop lowest), 4d6dh1
//   adv / dis  -> 2d20kh1 / 2d20kl1;  "adv+5", "1d20 adv +5" also work
//   d6!  (explode on max), d6!>5 (explode on >=5), d6!! (compound), 2d10r1 (reroll 1s, repeatedly), 2d10ro<2 (reroll once)
//   10d6>=5 or 10d6>4 (count successes), 10d10<3 (count successes at or below)
//   3#1d20+4  (roll the same expression 3 times)
//   append a label with a space and text: "1d20+5 attack", or use the reason argument
function main(args) {
  var input = String((args && (args.expression || args.dice || args.roll)) || '1d20').trim();
  var reason = args && args.reason ? String(args.reason) : '';
  var MAX_DICE = 1000, MAX_SIDES = 100000, MAX_EXPLODE = 100;

  function randInt(n) { return Math.floor(Math.random() * n) + 1; }

  function Lexer(s) {
    this.s = s.toLowerCase().replace(/\s+/g, '');
    this.i = 0;
  }
  Lexer.prototype.peek = function (n) { return this.s.substr(this.i, n || 1); };
  Lexer.prototype.eat = function (t) {
    if (this.s.substr(this.i, t.length) === t) { this.i += t.length; return true; }
    return false;
  };
  Lexer.prototype.num = function () {
    var m = /^\d+/.exec(this.s.slice(this.i));
    if (!m) return null;
    this.i += m[0].length;
    return parseInt(m[0], 10);
  };
  Lexer.prototype.fail = function (msg) {
    throw new Error(msg + ' at position ' + (this.i + 1) + ' in "' + this.s + '"');
  };

  function compare(lx) {
    var ops = ['>=', '<=', '>', '<', '='];
    for (var k = 0; k < ops.length; k++) {
      if (lx.eat(ops[k])) {
        var v = lx.num();
        if (v === null) lx.fail('expected a number after ' + ops[k]);
        return { op: ops[k], v: v };
      }
    }
    return null;
  }
  function test(c, x) {
    switch (c.op) {
      case '>=': return x >= c.v;
      case '<=': return x <= c.v;
      case '>': return x > c.v;
      case '<': return x < c.v;
      default: return x === c.v;
    }
  }

  // dice term: [count] d sides [modifiers]
  function dice(lx, count) {
    var sides;
    var fudge = false;
    if (lx.eat('%')) sides = 100;
    else if (lx.eat('f')) { fudge = true; sides = 3; }
    else {
      sides = lx.num();
      if (sides === null) lx.fail('expected number of sides after d');
    }
    if (count < 1 || count > MAX_DICE) lx.fail('dice count must be 1-' + MAX_DICE);
    if (sides < 1 || sides > MAX_SIDES) lx.fail('sides must be 1-' + MAX_SIDES);
    var label = count + 'd' + (fudge ? 'F' : (sides === 100 && lx.s[lx.i - 1] === '%' ? '%' : sides));
    var face = function () { return fudge ? randInt(3) - 2 : randInt(sides); };
    var mods = { keep: null, drop: null, explode: null, compound: false, reroll: null, rerollOnce: false, success: null };
    for (;;) {
      var start = lx.i;
      if (lx.eat('kl')) { mods.keep = { high: false, n: lx.num() || 1 }; }
      else if (lx.eat('kh') || lx.eat('k')) { mods.keep = { high: true, n: lx.num() || 1 }; }
      else if (lx.eat('adv')) { count = Math.max(count, 2); mods.keep = { high: true, n: 1 }; }
      else if (lx.eat('dis')) { count = Math.max(count, 2); mods.keep = { high: false, n: 1 }; }
      else if (lx.eat('dh')) { mods.drop = { high: true, n: lx.num() || 1 }; }
      else if (lx.eat('dl')) { mods.drop = { high: false, n: lx.num() || 1 }; }
      else if (lx.eat('!!')) { mods.explode = compare(lx) || { op: '>=', v: sides }; mods.compound = true; }
      else if (lx.eat('!')) { mods.explode = compare(lx) || { op: '>=', v: sides }; }
      else if (lx.eat('ro')) { mods.reroll = compare(lx) || { op: '=', v: lx.num() || 1 }; mods.rerollOnce = true; }
      else if (lx.eat('r')) { mods.reroll = compare(lx) || { op: '=', v: lx.num() || 1 }; }
      else if (/^(>=|<=|>|<)\d/.test(lx.s.slice(lx.i)) && !mods.success) { mods.success = compare(lx); }
      if (lx.i === start) break;
      label = label + lx.s.slice(start, lx.i);
    }
    if (mods.explode && !fudge && test(mods.explode, 1) && test(mods.explode, sides)) lx.fail('explode condition would never stop');
    if (mods.reroll && !mods.rerollOnce) {
      var all = true;
      for (var f = 1; f <= sides; f++) if (!test(mods.reroll, f)) { all = false; break; }
      if (all) lx.fail('reroll condition matches every face');
    }

    var rolls = []; // {v, shown, kept, notes}
    for (var c = 0; c < count; c++) {
      var v = face();
      var hist = [v];
      if (mods.reroll) {
        var guard = 0;
        while (test(mods.reroll, v) && guard++ < MAX_EXPLODE) {
          v = face(); hist.push(v);
          if (mods.rerollOnce) break;
        }
      }
      var shown = hist.length > 1 ? hist.slice(0, -1).map(function (x) { return '~' + x + '~'; }).join(' ') + ' ' + v : String(v);
      if (mods.explode) {
        if (mods.compound) {
          var total = v, last = v, g = 0;
          while (test(mods.explode, last) && g++ < MAX_EXPLODE) { last = face(); total += last; }
          if (total !== v) shown = total + '!';
          v = total;
          rolls.push({ v: v, shown: shown, kept: true });
        } else {
          rolls.push({ v: v, shown: shown + (test(mods.explode, v) ? '!' : ''), kept: true });
          var cur = v, g2 = 0;
          while (test(mods.explode, cur) && g2++ < MAX_EXPLODE) {
            cur = face();
            rolls.push({ v: cur, shown: cur + (test(mods.explode, cur) ? '!' : ''), kept: true });
          }
        }
      } else {
        rolls.push({ v: v, shown: shown, kept: true });
      }
    }
    var order = rolls.map(function (r, idx) { return idx; }).sort(function (a, b) { return rolls[a].v - rolls[b].v; });
    if (mods.keep) {
      var n = Math.min(mods.keep.n, rolls.length);
      var keepIdx = mods.keep.high ? order.slice(order.length - n) : order.slice(0, n);
      rolls.forEach(function (r, idx) { r.kept = keepIdx.indexOf(idx) >= 0; });
    }
    if (mods.drop) {
      var d = Math.min(mods.drop.n, rolls.length);
      var dropIdx = mods.drop.high ? order.slice(order.length - d) : order.slice(0, d);
      rolls.forEach(function (r, idx) { if (dropIdx.indexOf(idx) >= 0) r.kept = false; });
    }
    var value = 0, detail;
    if (mods.success) {
      var hits = 0;
      rolls.forEach(function (r) { if (r.kept && test(mods.success, r.v)) hits++; });
      value = hits;
      detail = '[' + rolls.map(function (r) { return r.kept ? (test(mods.success, r.v) ? '**' + r.shown + '**' : r.shown) : '~~' + r.shown + '~~'; }).join(', ') + '] successes';
    } else {
      rolls.forEach(function (r) { if (r.kept) value += r.v; });
      detail = '[' + rolls.map(function (r) {
        var s = fudge ? (r.v > 0 ? '+' : r.v < 0 ? '-' : '0') : r.shown;
        return r.kept ? s : '~~' + s + '~~';
      }).join(', ') + ']';
    }
    return { value: value, text: label + detail, nat: sides === 20 ? rolls.filter(function (r) { return r.kept; }).map(function (r) { return r.v; }) : [] };
  }

  // grammar: expr := term (('+'|'-') term)* ; term := factor (('*'|'/') factor)* ; factor := '-' factor | '(' expr ')' | atom
  function expr(lx) {
    var left = term(lx);
    for (;;) {
      if (lx.eat('+')) { var r = term(lx); left = { value: left.value + r.value, text: left.text + ' + ' + r.text, nat: left.nat.concat(r.nat) }; }
      else if (lx.eat('-')) { var r2 = term(lx); left = { value: left.value - r2.value, text: left.text + ' - ' + r2.text, nat: left.nat.concat(r2.nat) }; }
      else return left;
    }
  }
  function term(lx) {
    var left = factor(lx);
    for (;;) {
      if (lx.eat('*')) { var r = factor(lx); left = { value: left.value * r.value, text: left.text + ' × ' + r.text, nat: left.nat.concat(r.nat) }; }
      else if (lx.eat('/')) {
        var r2 = factor(lx);
        if (r2.value === 0) lx.fail('division by zero');
        left = { value: Math.floor(left.value / r2.value), text: left.text + ' ÷ ' + r2.text, nat: left.nat.concat(r2.nat) };
      } else return left;
    }
  }
  function factor(lx) {
    if (lx.eat('-')) { var f = factor(lx); return { value: -f.value, text: '-' + f.text, nat: f.nat }; }
    if (lx.eat('(')) {
      var e = expr(lx);
      if (!lx.eat(')')) lx.fail('missing )');
      return { value: e.value, text: '(' + e.text + ')', nat: e.nat };
    }
    if (lx.eat('adv') || lx.eat('dis')) {
      var l2 = new Lexer(lx.s.substr(lx.i - 3, 3) === 'adv' ? 'd20kh1' : 'd20kl1');
      l2.eat('d');
      return dice(l2, 2);
    }
    var n = lx.num();
    if (lx.eat('d')) return dice(lx, n === null ? 1 : n);
    if (n === null) lx.fail('unexpected "' + (lx.peek() || 'end') + '"');
    return { value: n, text: String(n), nat: [] };
  }
  function rollOne(src) {
    var lx = new Lexer(src);
    if (!lx.s) throw new Error('empty expression');
    var res = expr(lx);
    if (lx.i < lx.s.length) lx.fail('unexpected "' + lx.peek() + '"');
    return res;
  }

  var out = [];
  var parts = input.split(/[,;\n]/).map(function (p) { return p.trim(); }).filter(Boolean);
  if (parts.length > 20) throw new Error('at most 20 expressions per call');
  var grand = [];
  parts.forEach(function (p) {
    // split "expression label": the label starts at the first word that is not dice syntax
    var words = p.split(/\s+/), k = 0;
    while (k < words.length && /^(?:[0-9dfkhlr!<>=%+\-*\/()#]|adv|dis)+$/i.test(words[k]) &&
      (/[0-9()+\-*\/]/.test(words[k]) || /^(adv|dis)$/i.test(words[k]))) k++;
    if (k === 0) k = words.length;
    var exprStr = words.slice(0, k).join('');
    var label = words.slice(k).join(' ');
    // "1d20+5 adv": apply a trailing adv/dis to the first d20
    var ad = /^(.*?)(adv|dis)$/i.exec(exprStr);
    if (ad && /d20(?!\d)/i.test(ad[1])) exprStr = ad[1].replace(/\d*d20(?!\d)/i, 'd20' + ad[2].toLowerCase());
    var times = 1;
    var rep = /^(\d+)#(.+)$/.exec(exprStr);
    if (rep) { times = parseInt(rep[1], 10); exprStr = rep[2]; }
    if (times < 1 || times > 50) throw new Error('repeat count must be 1-50');
    for (var t = 0; t < times; t++) {
      var r = rollOne(exprStr);
      var crit = '';
      if (r.nat.length === 1) {
        if (r.nat[0] === 20) crit = ' — CRITICAL (nat 20)';
        else if (r.nat[0] === 1) crit = ' — FUMBLE (nat 1)';
      }
      var prefix = (label ? label + ': ' : '') + (times > 1 ? '#' + (t + 1) + ' ' : '');
      out.push(prefix + exprStr + ' → ' + r.text + ' = **' + r.value + '**' + crit);
      grand.push(r.value);
    }
  });
  var head = reason ? '🎲 ' + reason + '\n' : '🎲 ';
  var total = grand.length > 1 ? '\nTotal of all rolls: ' + grand.reduce(function (a, b) { return a + b; }, 0) : '';
  return head + out.join('\n') + total;
}
