function dukes_macdonald1(point_in_scale, select_rate, base_lapses, total_lapses, effectiveness)
  excess_lapses = total_lapses - base_lapses
  select_excess_lapses = effectiveness * excess_lapses
  not_lapses = 1 - total_lapses
  deteriorated_rate = (point_in_scale * (select_excess_lapses + not_lapses) - select_excess_lapses * select_rate) / not_lapses
  return deteriorated_rate
end

function dukes_macdonald2(point_in_scale, select_rate, base_lapses, total_lapses, effectiveness)
  excess_lapses = total_lapses - base_lapses
  select_excess_lapses = effectiveness * excess_lapses
  nonselect_excess_lapses = excess_lapses - select_excess_lapses
  not_lapses = 1 - total_lapses
  deteriorated_rate = (point_in_scale * (not_lapses + excess_lapses) - select_excess_lapses * select_rate) / (nonselect_excess_lapses + not_lapses)
  return deteriorated_rate
end

function dukes_macdonald3(point_in_scale, select_rate, base_lapses, total_lapses, effectiveness)
  excess_lapses = total_lapses - base_lapses
  select_excess_lapses = effectiveness * excess_lapses
  deteriorated_rate = (point_in_scale - select_excess_lapses * select_rate) / (1 - select_excess_lapses)
  return deteriorated_rate
end

