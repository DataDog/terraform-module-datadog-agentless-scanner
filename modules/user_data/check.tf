check "health_check" {
  data "http" "terraform_io" {
    url = "https://api.${var.site}/api/v1/validate"

    # Optional request headers
    request_headers = {
      Accept     = "application/json"
      DD-API-KEY = var.api_key

    }
  }
  assert {
    condition     = var.api_key == "" || data.http.terraform_io.status_code != 403
    error_message = "The Datadog site or API key is incorrect. Please verify your configuration."
  }
}
