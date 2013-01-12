class File::Stat
  alias ftype_orig ftype
  remove_method :ftype

  def door?
    mode & 0xF000 == 0xd000
  end

  def ftype
    if mode & 0xF000 == 0xd000
      "door"
    else
      ftype_orig
    end
  end
end
