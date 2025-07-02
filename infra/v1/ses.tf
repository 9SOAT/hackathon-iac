resource "aws_ses_email_identity" "semplates_email_identity" {
  email = var.verified_email
}

resource "aws_ses_template" "success_email_template" {
  name = "SUCCESS_EMAIL_TEMPLATE"
  subject = "Processamento de Vídeo Concluído"
  html = file("${path.module}/static/success_email_template.html")
}

resource "aws_ses_template" "failure_email_template" {
  name = "FAILURE_EMAIL_TEMPLATE"
  subject = "Falha no Processamento de Vídeo"
  html = file("${path.module}/static/failure_email_template.html")
}