var currentDangle, currentRangle, bevelDangle, bevelRangle, miterDangle, miterRangle, springDangle, springRangle, isWall = true, fromDangle = 60, toDangle = 145, lastWallDangle = 90, lastRoofDangle = 10, isClr = true;
function Setup() {
  SetImperialSelect();
  SetAnimFrame();
  Calculate();
  SetNumeric();
}
function Calculate() {
  isValid = true;
  currentDangle = parseCheck("txtAngle", (isWall ? "Wall" : " Roof") + "Angle", fromDangle, toDangle);
  springDangle = parseCheck("txtSpringAngle", "Spring Angle", 30, 50);
  if (isValid) {
    isClr = $("cbColor").checked;
    springRangle = RAD * springDangle;
    currentRangle = currentDangle * RAD;
    if (isWall) 
    {
        miterRangle = Math.atan(Math.sin(springRangle) / Math.tan(currentRangle / 2));
        bevelRangle = Math.asin(Math.cos(springRangle) * Math.cos(currentRangle / 2));
    } 
    else 
    {
      var d = (180 - 2 * currentDangle) / 2;
      miterRangle = Math.atan(Math.cos(springRangle) / Math.tan(d * RAD));
      bevelRangle = Math.asin(Math.sin(springRangle) * Math.cos(d * RAD));
    }
    miterDangle = miterRangle / RAD;
    bevelDangle = bevelRangle / RAD;
    $("spnRes").innerHTML = (isWall ? "Wall Corner" : "Roof Pitch") + " Angle <span style=color:red>" + RoundTo(currentDangle, 1) + "&deg;</span><br />Miter " + RoundTo(miterDangle, 1) + "&deg; &nbsp; Bevel <span style=color:blue>" + RoundTo(bevelRangle / RAD, 1) + "&deg;</span><br />Spring Angle " + springDangle + "&deg;";
    $("spnSpringAngle").innerHTML = "Molding Spring Angle " + springDangle + "&deg;";
    d = $("cnvsAngle");
    var a = d.getContext("2d"), e = isWall ? currentRangle : RAD180 - 2 * currentRangle, c = e / RAD, b = 250 * Math.sin(e / 2);
    d.width = 2 * b + 20;
    var f = d.width / 2, g = 250 * Math.cos(e / 2);
    d.height = Math.max(140, g + 40);
    a.save();
    a.translate(0, 30);
    a.beginPath();
    a.moveTo(f - b, g);
    a.lineTo(f, 0);
    a.lineTo(f + b, g);
    a.lineWidth = 4;
    a.stroke();
    a.lineWidth = 1;
    a.beginPath();
    a.arc(f, 2, 60, (90 - c / 2) * RAD, (90 + c / 2) * RAD, false);
    a.lineTo(f, 2);
    a.closePath();
    isClr && (a.fillStyle = "#f00", a.fill());
    a.strokeStyle = "silver";
    a.stroke();
    a.fillStyle = isClr ? "#fff" : "000";
    a.font = "14px Verdana";
    a.textAlign = "center";
    a.fillText(Math.round(c) + "°", f, 40);
    a.save();
    a.translate(f - b, g - 3);
    a.rotate(isWall ? -(RAD90 - e / 2) : -currentDangle * RAD);
    a.textAlign = "left";
    a.textBaseline = "bottom";
    a.fillStyle = "#000";
    a.fillText(isWall ? " Wall" : " ← " + currentDangle + "° →", 0, 0);
    a.restore();
    a.save();
    a.translate(f + b, g - 3);
    a.rotate(RAD90 - e / 2);
    a.textAlign = "right";
    a.textBaseline = "bottom";
    a.fillStyle = "#000";
    a.fillText(isWall ? "Wall " : "Roof ", 0, 0);
    a.restore();
    a.fillStyle = "#000";
    a.textAlign = "center";
    a.font = "12px Verdana";
    a.fillText("Miter " + RoundTo(miterDangle, 1) + "°", f, 80);
    a.fillText("Bevel " + RoundTo(bevelDangle, 1) + "°", f, 100);
    a.font = "18px Verdana";
    a.fillText((isWall ? "Wall Corner" : "Roof Pitch") + " Angle " + currentDangle + "°", f, -10);
    a.restore();
    isWall ? lastWallDangle = currentDangle : lastRoofDangle = currentDangle;
    DrawMiter();
    DrawBevel();
    DrawSpringAngle();
    DrawTable();
    $("rngAngle").value = currentDangle;
    $("rngSpringAngle").value = springDangle;
  }
}
function DrawMiter() {
  var d = $("cnvsMiterAngle"), a = d.width - 2, e = a / 2 - 5, c = e - 80;
  d.height = 0.52 * a;
  a = d.getContext("2d");
  a.clearRect(0, 0, d.width, d.height);
  a.save();
  a.translate(5, 2);
  a.strokeStyle = "Silver";
  a.beginPath();
  a.arc(e, 0, e, 0, RAD180, false);
  a.arc(e, 0, c, RAD180, 0, true);
  a.closePath();
  isClr && (a.fillStyle = "#7CFC00", a.fill());
  a.stroke();
  a.beginPath();
  a.moveTo(e - c + 10, 0);
  a.lineTo(e + c - 10, 0);
  a.stroke();
  var b = 60, f = 30 * RAD;
  a.textBaseline = "top";
  a.font = "bold 16px Arial";
  a.strokeStyle = "#777";
  a.fillStyle = "#000";
  a.textAlign = "center";
  for (a.beginPath(); f < 150 * RAD;) {
    var g = 20;
    0 === b % 10 ? g = 30 : 0 === b % 5 && (g = 25);
    var h = e + c * Math.cos(f);
    d = c * Math.sin(f);
    a.moveTo(h, d);
    h = e + (c + g) * Math.cos(f);
    d = (c + g) * Math.sin(f);
    a.lineTo(h, d);
    0 === b % 10 && (a.save(), a.translate(h, d), a.rotate(-RAD90 + f), a.fillText(Math.abs(b), 0, 0), a.restore());
    b--;
    f += RAD;
  }
  a.stroke();
  a.drawImage($("imgSawMiter"), 130, 10);
  c += 12;
  h = c * Math.sin(miterRangle);
  d = c * Math.cos(miterRangle);
  a.strokeStyle = "#f00";
  a.lineCap = "round";
  a.lineWidth = 2;
  a.beginPath();
  a.moveTo(e + h, d);
  a.lineTo(e, 0);
  a.stroke();
  a.font = "14px Verdana";
  a.textAlign = "left";
  a.fillStyle = "#00f";
  b = RAD90 - miterRangle;
  h = e + c / 4 * Math.cos(b);
  d = c / 4 * Math.sin(b);
  a.save();
  a.translate(h, d);
  a.rotate(b);
  a.textBaseline = "bottom";
  a.fillText("Miter Angle", 0, 0);
  a.restore();
  a.textAlign = "center";
  a.save();
  a.font = "40px Verdana";
  a.translate(220, 150);
  a.rotate(RAD180);
  a.fillText("↶", 0, 0);
  a.restore();
  a.font = "Bold 20px Verdana";
  a.fillStyle = "$00f";
  a.fillText("Miter " + RoundTo(miterDangle, 1) + "°", 226, 146);
  a.restore();
}
function DrawBevel() {
  var d = $("cnvsBevelAngle"), a = d.width - 2, e = a - 80;
  d.height = a + 20;
  var c = d.getContext("2d");
  c.clearRect(0, 0, d.width, d.height);
  c.save();
  c.translate(2, 2);
  c.strokeStyle = "Silver";
  c.beginPath();
  c.arc(0, a, a, RAD270, 0, false);
  c.arc(0, a, e, 0, RAD270, true);
  c.closePath();
  isClr && (c.fillStyle = "#05E9FF", c.fill());
  c.stroke();
  c.beginPath();
  c.moveTo(0, a - e + 10);
  c.lineTo(0, a);
  c.lineTo(e - 10, a);
  c.stroke();
  c.font = "bold 14px Arial";
  c.fillStyle = "#000";
  c.strokeStyle = "#777";
  var b = d = 0;
  c.textAlign = "left";
  for (c.beginPath(); d < 51 * RAD;) {
    var f = 20;
    0 === b % 10 ? f = 30 : 0 === b % 5 && (f = 25);
    var g = e * Math.cos(d);
    var h = a - e * Math.sin(d);
    c.moveTo(g, h);
    g = (e + f) * Math.cos(d);
    h = a - (e + f) * Math.sin(d);
    c.lineTo(g, h);
    0 === b % 10 && 0 < b && (c.save(), c.translate(g, h), c.rotate(-d), c.fillText(b, 4, 4), c.restore());
    d += RAD;
    b++;
  }
  c.stroke();
  c.drawImage($("imgSawAngle"), 2, 98);
  g = (e + 12) * Math.cos(bevelRangle);
  h = a - (e + 12) * Math.sin(bevelRangle);
  c.save();
  c.strokeStyle = "#f00";
  c.lineCap = "round";
  c.lineWidth = 2;
  c.beginPath();
  c.moveTo(0, a);
  c.lineTo(g, h);
  c.stroke();
  c.restore();
  c.font = "14px Verdana";
  c.fillStyle = "#00f";
  g = 0.2 * a * Math.cos(bevelRangle);
  h = a - 0.2 * a * Math.sin(bevelRangle);
  c.save();
  c.translate(g, h);
  c.rotate(-bevelRangle);
  c.fillText("Bevel Angle", 0, -4);
  c.restore();
  c.textAlign = "center";
  c.font = "40px Verdana";
  c.fillText("↶", 45, 110);
  c.font = "Bold 20px Verdana";
  c.fillStyle = "$00f";
  c.fillText("Bevel " + RoundTo(bevelDangle, 1) + "°", 70, 240);
  c.restore();
}
function DrawSpringAngle() {
  var d = springDangle * RAD, a = $("cnvsSpringAngle"), e = a.width - 10, c = a.height - 10, b = a.getContext("2d");
  b.clearRect(0, 0, a.width, a.height);
  b.strokeStyle = "silver";
  b.beginPath();
  b.moveTo(0, 0);
  b.lineTo(e, 0);
  b.lineTo(e, 20.5);
  b.lineTo(20.5, 20.5);
  b.lineTo(20.5, c);
  b.lineTo(0, c);
  b.closePath();
  b.fillStyle = b.createPattern($("imgWood"), "repeat");
  b.fill();
  b.stroke();
  a = 20.5 + 340 * Math.sin(d);
  var f = 20.5 + 340 * Math.cos(d);
  b.beginPath();
  b.moveTo(a, 22.5);
  b.lineTo(a, 40.5);
  b.lineTo(a - 20, 40.5);
  b.lineTo(20.5 + a / 2 - 24, 20.5 + f / 2 - 24);
  b.lineTo(40.5, f - 20);
  b.lineTo(40.5, f);
  d = f - 40 / Math.sin(d);
  var g = a - 40 / Math.sin((90 - springDangle) * RAD);
  b.lineTo(22.5, f);
  b.lineTo(22.5, d);
  b.lineTo(g, 22.5);
  b.closePath();
  b.fillStyle = "#e3e3e3";
  b.fill();
  b.stroke();
  b.font = "13px Verdana";
  b.fillStyle = "#fff";
  b.textAlign = "center";
  b.fillText("Ceiling", 0.8 * e, 14);
  b.save();
  b.translate(8, 0.8 * c);
  b.rotate(RAD90);
  b.fillText("Wall", 0, 0);
  b.restore();
  b.fillStyle = "#000";
  b.save();
  b.translate(a / 2 - 6, f / 2 - 6);
  b.rotate(-(90 - springDangle) * RAD);
  b.fillText("Molding", 0, 0);
  b.restore();
  b.save();
  b.textAlign = "right";
  b.translate(24.5, d - 20);
  b.rotate(RAD90);
  b.fillText("Spring Angle " + RoundTo(springDangle, 1) + "°", 0, 0);
  b.restore();
  b.fillText(RoundTo(90 - springDangle, 1) + "°", g - 24, 32.5);
  b.font = "18px Verdana";
  b.fillStyle = "#00f";
  b.fillText("Spring Angle " + RoundTo(springDangle, 1) + "°", 0.7 * e, 0.5 * c);
}
function DrawTable() {
  var d = $("tblMold"), a = $("tblMold2"), e;
  for (e = d.rows.length - 1; 0 < e; e--) d.deleteRow(e);
  for (e = a.rows.length - 1; 0 < e; e--) a.deleteRow(e);
  var c = 0, b = Math.floor((toDangle - fromDangle) / 2) + 1;
  for (e = fromDangle; e <= toDangle; e++) {
    c++ === b && (d = a);
    if (isWall) miterRangle = Math.atan(Math.sin(springRangle) / Math.tan(e * RAD / 2)), bevelRangle = Math.asin(Math.cos(springRangle) * Math.cos(e * RAD / 2)); else {
      var f = (180 - 2 * e) / 2;
      miterRangle = Math.atan(Math.cos(springRangle) / Math.tan(f * RAD));
      bevelRangle = Math.asin(Math.sin(springRangle) * Math.cos(f * RAD));
    }
    f = document.createElement("tr");
    var g = document.createElement("td");
    g.innerHTML = e;
    f.appendChild(g);
    isClr && e === currentDangle && (g.className = "selected1");
    g = document.createElement("td");
    g.innerHTML = RoundTo(miterRangle / RAD, 1) + "&deg;";
    f.appendChild(g);
    isClr && e === currentDangle && (g.className = "selected2");
    g = document.createElement("td");
    g.innerHTML = RoundTo(bevelRangle / RAD, 1) + "&deg;";
    f.appendChild(g);
    isClr && e === currentDangle && (g.className = "selected3");
    f.id = e + "_tr";
    d.appendChild(f);
    f.onclick = function () {
      $("txtAngle").value = parseInt(this.id);
      Calculate();
    };
  }
}
function rngAngle_Change(d) {
  $("txtAngle").value = d.value;
  CallAnim();
}
function rngSpringAngle_Change(d) {
  $("txtSpringAngle").value = d.value;
  CallAnim();
}
function ReSpring(d) {
  $("txtSpringAngle").value = d;
  Calculate();
}
function SetType(d) {
  isWall = "w" === d;
  $("spnType").innerHTML = isWall ? "Wall Angle" : "Roof Angle";
  $("spnType2").innerHTML = $("spnType3").innerHTML = $("spnRangeLabel").innerHTML = isWall ? "Wall" : "Roof";
  fromDangle = isWall ? 60 : 1;
  toDangle = isWall ? 136 : 45;
  $("rngAngle").min = fromDangle;
  $("rngAngle").max = toDangle;
  $("txtAngle").value = isWall ? lastWallDangle : lastRoofDangle;
  Calculate();
}
function CallAnim() {
  requestAnimFrame(function () {
    Calculate();
  });
}
;
