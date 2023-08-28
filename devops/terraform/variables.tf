# SOURCE: https://stackoverflow.com/a/76194380/15454191
locals {
  dot_env_file_path = "./.env"
  dot_env_regex     = "(?m:^\\s*([^#\\s]\\S*)\\s*=\\s*[\"']?(.*[^\"'\\s])[\"']?\\s*$)"
  dot_env           = { for tuple in regexall(local.dot_env_regex, file(local.dot_env_file_path)) : tuple[0] => sensitive(tuple[1]) }
  api_token     = local.dot_env["API_TOKEN"]
}
