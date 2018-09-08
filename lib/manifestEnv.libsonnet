{
  # Similar to std.MinifestIni(), but creates items in an .env file
  manifestEnv(env)::
    local body_lines(body) =
      std.join([], [
        local value_or_values = body[k];
        if std.type(value_or_values) == 'array' then
          ['%s=%s' % [k, value] for value in value_or_values]
        else
          ['%s=%s' % [k, value_or_values]]

        for k in std.objectFields(body)
      ]);

    std.join('\n', body_lines(env)),
}