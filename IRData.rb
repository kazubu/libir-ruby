class IRData
  @data = []
  @format = nil

  T = {
    :aeha => 425.0,
    :nec => 562.0,
    :sony => 600.0
  }

  def data
    @data
  end

  def format
    @format
  end

  def data_inspect
    case @format
    when :aeha
      data_inspect_aeha
    when :nec
      data_inspect_nec
    when :sony
      data_inspect_sony
    else
      nil
    end
  end

  def data_inspect_aeha
    data = @data.map{|v| (v / T[:aeha]).to_i}
    data_bin = "" 
    for i in 1..((data.size/2)-1)
      d1 = data[i*2].to_i
      d2 = data[1+i*2].to_i

      if d1 == 1 && d2 == 3
        data_bin << "1"
      elsif d1 == 1 && d2 == 1
        data_bin << "0"
      end
    end

    data_hex = [data_bin].pack("B*").unpack("H*")[0]

    return {
      :customer_code => data_hex[0..3],
      :parity => data_hex[4],
      :data0 => data_hex[5],
      :datan => data_hex[6..data_hex.length],
      :data_hex => data_hex
    }
  end

  def data_inspect_nec
    raise 'not implemented yet'
  end

  def data_inspect_sony
    raise 'not implemented yet'
  end

private

  def initialize(data)
    @data = data
    @format = format?
    @data = FixAlignment(@data, @format)
  end

  def FixAlignment(data, type)
    t = T[type]
    data.map{|v|((v/(t)).round)*t.to_i}
  end

  def check_nec(data)
    (data[0] == 16*562 && data[1] == 8*562) # Leader:16T8T
  end

  def check_aeha(data)
    (data[0] == 8*425 && data[1] == 4*425) # Leader:8T4T
  end

  def check_sony(data)
    (data[0] == 4*600 && data[1] == 1*600) # Leader:4T, next data must be started by 1T
  end

  def format?
    return :sony if check_sony FixAlignment(@data, :sony)
    return :aeha if check_aeha FixAlignment(@data, :aeha)
    return :nec if check_nec FixAlignment(@data, :nec)
  end
end