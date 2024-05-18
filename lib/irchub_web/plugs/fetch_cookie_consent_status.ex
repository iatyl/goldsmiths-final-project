defmodule IrchubWeb.Plugs.FetchCookieConsentStatus do
  import Plug.Conn
  alias IrchubWeb.CookieConsentController

  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts) do
    key = CookieConsentController.cookie_consent_key_str()
    val_str = CookieConsentController.cookie_consent_val_str()
    cookie_consent_status = get_session(conn, key, false)
    cookie_consent_status = cookie_consent_status || Map.get(conn.cookies, key) == val_str

    assign(conn, :cookie_consent_status, cookie_consent_status)
    end
end
