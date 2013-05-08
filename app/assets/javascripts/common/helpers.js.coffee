if not String::trim?
  String::trim = -> this.replace /^\s+|\s+$/g, ''
