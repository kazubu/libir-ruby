class IRData
  @data = []
  @format = nil

  attr_reader :data, :format

  T = {
    :aeha => 425,
    :nec => 562,
    :sony => 600
  }

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

  def self.new_by_str(data, format)
    raise "unknown format" if T[format].nil?
    case format
    when :aeha
      return self.new(create_data_aeha(data))
    when :nec
      return self.new(create_data_nec(data))
    when :sony
      return self.new(create_data_sony(data))
    end
  end

private

  def initialize(data)
    @data = data
    @format = format?
    @data = FixAlignment(@data, @format)
  end

  def data_inspect_aeha
    data = @data.map{|v| (v / T[:aeha])}
    data_bin = ""
    data.each_slice(2){|a|
      data_bin << "1" if a == [1,3]
      data_bin << "0" if a == [1,1]
    }

    data_hex = [data_bin].pack("B*").unpack("H*")[0]

    return {
      :customer_code => data_hex[0..3],
      :parity => data_hex[4],
      :data0 => data_hex[5],
      :datan => data_hex[6..data_hex.length],
      :datan_rev => [data_hex[6..data_hex.length]].pack("H*").unpack("B*").pack("b*").unpack("H*"),
      :data_hex => data_hex
    }
  end

  def data_inspect_nec
    raise 'not implemented yet'
    data = @data.map{|v| (v / T[:nec])}
  end

  def data_inspect_sony
    raise 'not implemented yet'
    data = @data.map{|v| (v / T[:sony])}
  end

  def self.create_data_aeha(hexstr)
    data = []
    data << 8*T[:aeha]
    data << 4*T[:aeha]
    binstr = [hexstr].pack("H*").unpack("B*")[0]
    binstr.each_char{|c|
      if c == "0"
        data << 1*T[:aeha]
        data << 1*T[:aeha]
      elsif c == "1"
        data << 1*T[:aeha]
        data << 3*T[:aeha]
      end
    }
    data << 1*T[:aeha] # Trailer

    return data
  end

  def self.create_data_nec(hexstr)
    data = []
    data << 16*T[:nec]
    data << 8*T[:nec]
    binstr = [hexstr].pack("H*").unpack("B*")[0]
    binstr.each_char{|c|
      if c == "0"
        data << 1*T[:nec]
        data << 1*T[:nec]
      elsif c == "1"
        data << 1*T[:nec]
        data << 3*T[:nec]
      end
    }
    data << 1*T[:nec] # Trailer

    return data
  end


  def self.create_data_sony(hexstr)
    raise 'not implemented yet'
  end



  def FixAlignment(data, type)
    t = T[type]
    data.map{|v|((v/t.to_f).round)*t}
  end

  def check_nec(data)
    (data[0] == 16*T[:nec] && data[1] == 8*T[:nec] ) # Leader:16T8T
  end

  def check_aeha(data)
    (data[0] == 8*T[:aeha] && data[1] == 4*T[:aeha]) # Leader:8T4T
  end

  def check_sony(data)
    (data[0] == 4*T[:sony] && data[1] == 1*T[:sony]) # Leader:4T, next data must be started by 1T
  end

  def format?
    return :sony if check_sony FixAlignment(@data, :sony)
    return :aeha if check_aeha FixAlignment(@data, :aeha)
    return :nec if check_nec FixAlignment(@data, :nec)
  end
end
