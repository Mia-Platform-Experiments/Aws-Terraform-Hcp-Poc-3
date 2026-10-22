variable "web__module_source" {
  default = "git::https://github.com/dlafficare/tf-aws-spa.git?ref=v1.1.0"
}

variable "web_service_name" {
  description = "Name of the bucket: globally unique, lowercase letters, numbers and hyphens."
  type        = string
  default     = "aws-poc-3-web"
}

variable "web_performance_profile" {
  description = "The performance tier (sandbox, development, production). The module configures the details based on this profile."
  type        = string
  default     = "sandbox"
}

variable "web_index_html" {
  description = "Inline HTML page published as index.html. Leave empty to publish the build of a microservice instead. Do not use the character sequence dollar + open brace."
  type        = string
  default     = <<-EOT
<!doctype html>
<!-- Inline page for the Console form: do not use template literals (dollar + brace). -->
<html lang="it">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>AWS POC - Somma</title>
  <style>
    body { font-family: system-ui, sans-serif; max-width: 420px; margin: 48px auto; padding: 0 16px; color: #1f2937; }
    h1 { font-size: 22px; }
    section { border: 1px solid #e5e7eb; border-radius: 8px; padding: 16px; margin-bottom: 16px; }
    label { display: block; font-size: 13px; margin: 8px 0 4px; }
    input { width: 100%; box-sizing: border-box; padding: 8px; border: 1px solid #d1d5db; border-radius: 6px; }
    button { margin-top: 12px; padding: 8px 16px; border: 0; border-radius: 6px; background: #0b5cff; color: #fff; cursor: pointer; }
    .row { display: flex; gap: 8px; }
    .out { margin-top: 12px; font-weight: 600; }
    .err { color: #b91c1c; }
    .hidden { display: none; }
  </style>
</head>
<body>
  <h1>AWS POC &middot; Somma</h1>

  <section id="login">
    <label for="user">Email</label>
    <input id="user" type="email" autocomplete="username">
    <label for="pass">Password</label>
    <input id="pass" type="password" autocomplete="current-password">
    <button id="login-btn">Accedi</button>
    <div id="login-msg" class="out"></div>
  </section>

  <section id="app" class="hidden">
    <div class="row">
      <div><label for="a">A</label><input id="a" type="number" value="2"></div>
      <div><label for="b">B</label><input id="b" type="number" value="3"></div>
    </div>
    <button id="sum-btn">Somma</button>
    <div id="sum-out" class="out"></div>
    <div id="stats-out"></div>
  </section>

  <script>
    var config = null;
    var idToken = null;

    function show(id, text, isError) {
      var el = document.getElementById(id);
      el.textContent = text;
      el.className = isError ? "out err" : "out";
    }

    async function loadConfig() {
      var res = await fetch("config.json", { cache: "no-store" });
      config = await res.json();
    }

    async function login() {
      show("login-msg", "Accesso in corso...");
      var res = await fetch("https://cognito-idp." + config.region + ".amazonaws.com/", {
        method: "POST",
        headers: {
          "Content-Type": "application/x-amz-json-1.1",
          "X-Amz-Target": "AWSCognitoIdentityProviderService.InitiateAuth"
        },
        body: JSON.stringify({
          AuthFlow: "USER_PASSWORD_AUTH",
          ClientId: config.clientId,
          AuthParameters: {
            USERNAME: document.getElementById("user").value,
            PASSWORD: document.getElementById("pass").value
          }
        })
      });
      var data = await res.json();
      if (!res.ok || !data.AuthenticationResult) {
        show("login-msg", "Login fallito: " + (data.message || res.status), true);
        return;
      }
      idToken = data.AuthenticationResult.IdToken;
      document.getElementById("login").classList.add("hidden");
      document.getElementById("app").classList.remove("hidden");
      loadStats();
    }

    async function callApi(method, path, body) {
      var res = await fetch(config.apiUrl + path, {
        method: method,
        headers: { "Authorization": "Bearer " + idToken, "Content-Type": "application/json" },
        body: body ? JSON.stringify(body) : undefined
      });
      return { ok: res.ok, status: res.status, data: await res.json().catch(function () { return {}; }) };
    }

    async function sum() {
      var r = await callApi("POST", "/sum", {
        a: Number(document.getElementById("a").value),
        b: Number(document.getElementById("b").value)
      });
      if (!r.ok) {
        show("sum-out", "Errore " + r.status + ": " + (r.data.error || r.data.message || ""), true);
        return;
      }
      show("sum-out", r.data.a + " + " + r.data.b + " = " + r.data.result);
      loadStats();
    }

    async function loadStats() {
      var r = await callApi("GET", "/stats");
      document.getElementById("stats-out").textContent = r.ok ? "Somme calcolate finora: " + r.data.calls : "";
    }

    document.getElementById("login-btn").addEventListener("click", login);
    document.getElementById("sum-btn").addEventListener("click", sum);
    loadConfig();
  </script>
</body>
</html>

EOT
}

variable "web_deployed_service" {
  description = "Name of the microservice (in the Console) whose build is published, when index_html is empty."
  type        = string
  default     = ""
}

variable "web_artifacts_bucket" {
  description = "Bucket where microservice pipelines upload their builds."
  type        = string
  default     = "aws-demo-artifacts"
}

variable "web_runtime_config" {
  description = "Values published as /config.json, as a JSON object. Use ref:<resource>.<output> to link other resources."
  type        = string
  default     = <<-EOT
{"apiUrl": "ref:api.api_url", "userPoolId": "ref:cognito-auth.user_pool_id", "clientId": "ref:cognito-auth.client_id", "region": "ref:cognito-auth.region"}
EOT
}

variable "web_additional_tags" {
  description = "Additional tags as a JSON object (optional)."
  type        = string
  default     = <<-EOT
{}
EOT
}
