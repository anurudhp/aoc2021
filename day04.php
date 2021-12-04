<?php
$values = explode(",", readline());

$best_turns = 100000000;
$best_value = 0;

$worst_turns = 0;
$worst_value = 0;

function process_one() {
  global $values, $best_turns, $best_value, $worst_turns, $worst_value;
  $grid = array();
  $rowb = array();
  $colb = array();
  $sum = 0;
  for ($i = 0; $i < 5; $i++) {
    $grid[$i] = sscanf(readline(), "%d %d %d %d %d");
    foreach ($grid[$i] as $x) $sum += $x;
    $rowb[$i] = 0;
    $colb[$i] = 0;
  }
  $turns = 0;
  foreach ($values as $x) {
    $turns++;
    for ($i = 0; $i < 5; $i++) {
      for ($j = 0; $j < 5; $j++) {
        if ($grid[$i][$j] == $x) {
          $sum -= $grid[$i][$j];
          $grid[$i][$j] = -1;
          $rowb[$i]++;
          $colb[$j]++;
          if ($rowb[$i] == 5 or $colb[$j] == 5) {
            if ($best_turns > $turns) {
              $best_turns = $turns;
              $best_value = $sum * $x;
            }
            if ($worst_turns < $turns) {
              $worst_turns = $turns;
              $worst_value = $sum * $x;
            }
            return;
          }
        }
      }
    }
  }
}

while(readline() !== false) {
  process_one();
}
echo ">>>>>>>>>>>>>>>>>>>>>>>>\n";
echo $best_value, " ", $worst_value;
?>
