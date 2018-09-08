// Render any jsonnet value (except functions) to TOML format.
//
// Please note: it is still possible to create invalid TOML here!
// The TOML spec disallows mixed-type arrays, but this function doesn't
// explicitly check for that.

local
  inlineTable(body) =
    "{" +
    std.join(", ", ["%s = %s" % [escapeKeyToml(k), renderBody(body[k])] for k in std.objectFields(body)]) +
    "}",

  renderArray(body) = "[" + std.join(", ", [renderBody(x) for x in body]) + "]",

  renderBody(body) =
    if std.type(body) == "object"  then inlineTable(body) else
    if std.type(body) == "array"   then renderArray(body) else
    if std.type(body) == "number"  then body else
    if std.type(body) == "string"  then escapeStringToml(body) else
    if std.type(body) == "boolean" then body else
      error "unsupported value for toml: got %s" % std.type(body),

  renderTop(k, v) =
    if std.type(v) == "object" then "[%s]\n" % escapeKeyToml(k) + topTable(v)
    else "%s = %s" % [escapeKeyToml(k), renderBody(v)],

  topTable(body) =
    std.lines(["%s = %s" % [escapeKeyToml(k), renderBody(body[k])] for k in std.objectFields(body)]),

  escapeKeyToml(str) =
    local bare_allowed = std.set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-");
    if std.setUnion(std.set(str), bare_allowed) == bare_allowed then str else "%s" % escapeStringToml(str),

  // I think this is the same escaping rules as json?
  escapeStringToml = std.escapeStringJson;

function(body)
  if std.type(body) != "object"
    then error "TOML body must be an object. Got %s" % std.type(body)
    else std.lines(
        [renderTop(k, body[k]) for k in std.objectFields(body) if std.type(body[k]) != "object"]
      + [""]
      + [renderTop(k, body[k]) for k in std.objectFields(body) if std.type(body[k]) == "object"])
