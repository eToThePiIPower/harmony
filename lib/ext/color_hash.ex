defmodule ColorHash do
  @hue_range {0, 360}
  @sat_range {40, 100}
  @lit_range {45, 75}

  def hash(string) do
    {min_h, max_h} = @hue_range
    {min_s, max_s} = @sat_range
    {min_l, max_l} = @lit_range

    hue = :erlang.phash2(string <> ":hue", max_h - min_h) + min_h
    sat = :erlang.phash2(string <> ":sat", max_s - min_s) + min_s
    lit = :erlang.phash2(string <> ":lit", max_l - min_l) + min_l

    {hue, sat, lit}
  end

  def hsl_to_css({h, s, l}) do
    "hsl(#{h}, #{s}%, #{l}%)"
  end
end
