resource "random_id" "server" {
  keepers = {
    ami_id = 1
  }

  byte_length = 8
}

resource random_integer "password-length" {
  min = 12
  max = 25
}

resource "random_password" "bigippassword" {
  length           = random_integer.password-length.result
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  special          = true
  override_special = "_%@"
}

