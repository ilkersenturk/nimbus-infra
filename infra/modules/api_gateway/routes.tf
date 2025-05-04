# Route: ANY /{proxy+} — catch all paths
resource "aws_apigatewayv2_route" "proxy_route" {
  api_id    = aws_apigatewayv2_api.backend_api.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.backend_integration.id}"
}

# Deployment
resource "aws_apigatewayv2_deployment" "deployment" {
  api_id = aws_apigatewayv2_api.backend_api.id

  depends_on = [
    aws_apigatewayv2_route.proxy_route
  ]
}

# Stage
resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.backend_api.id
  name        = "prod"
  # when auto deploy is true u can not pass deployment id
  # deployment_id = aws_apigatewayv2_deployment.deployment.id

  auto_deploy = true
}