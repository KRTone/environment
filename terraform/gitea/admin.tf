resource "gitea_user" "admin" {
  username             = var.admin_username
  login_name           = var.admin_username
  password             = var.admin_password
  email                = var.admin_email
  admin                = true
  must_change_password = false

  depends_on = [time_sleep.wait_for_gitea]
}
