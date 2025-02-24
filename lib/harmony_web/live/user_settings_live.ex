defmodule HarmonyWeb.UserSettingsLive do
  use HarmonyWeb, :live_view

  alias Harmony.Accounts

  def render(assigns) do
    ~H"""
    <div class="flex flex-col w-full md:flex-row">
      <div class="mx-auto w-96 mt-16">
        <.header class="text-center">
          Profile settings
          <:subtitle>Manage your account email address and password settings</:subtitle>
        </.header>

        <div class="space-y-12 divide-y">
          <.simple_form
            for={@profile_form}
            id="profile_form"
            phx-submit="update_profile"
            phx-change="validate_profile"
          >
            <.input field={@profile_form[:display_name]} label="Display Name" required />
            <.input field={@profile_form[:about_me]} type="textarea" label="About me" required />
            <div class="flex flex-row gap-4">
              <.live_img_preview
                :if={Enum.any?(@uploads.avatar.entries)}
                id="avatar-preview"
                entry={List.first(@uploads.avatar.entries)}
                class="rounded-lg inline w-[64px] h-[64px]"
                width={64}
                height={64}
              />
              <div>
                <.label for={@uploads.avatar.ref}>Avatar</.label>
                <.live_file_input
                  upload={@uploads.avatar}
                  aria-described-by="avatar_input_help"
                  class="block w-full mt-2 rounded-lg text-zinc-900 border border-zinc-300 bg-zinc-50 file:bg-zinc-900 file:hover:bg-zinc-700 file:text-sm file:font-semibold file:text-white"
                />
                <p class="mt-1 text-sm text-gray-700" id="avatar_input_help">
                  PNG or JPG (MAX. 512x512px, 2MB).
                </p>
              </div>
            </div>
            <:actions>
              <.button class="w-full" phx-disable-with="Changing...">Update profile</.button>
            </:actions>
          </.simple_form>
        </div>
      </div>

      <div class="mx-auto w-96 mt-16">
        <.header class="text-center">
          Account Settings
          <:subtitle>Manage your account email address and password settings</:subtitle>
        </.header>

        <div class="space-y-12 divide-y">
          <.simple_form
            for={@email_form}
            id="email_form"
            phx-submit="update_email"
            phx-change="validate_email"
          >
            <.input field={@email_form[:email]} type="email" label="Email" required />
            <.input field={@email_form[:username]} label="Username" required />
            <.input
              field={@email_form[:current_password]}
              name="current_password"
              id="current_password_for_email"
              type="password"
              label="Current password"
              value={@email_form_current_password}
              required
            />
            <:actions>
              <.button class="w-full" phx-disable-with="Changing...">
                Change Email and Username
              </.button>
            </:actions>
          </.simple_form>
        </div>

        <div>
          <.simple_form
            for={@password_form}
            id="password_form"
            action={~p"/users/log_in?_action=password_updated"}
            method="post"
            phx-change="validate_password"
            phx-submit="update_password"
            phx-trigger-action={@trigger_submit}
          >
            <input
              name={@password_form[:email].name}
              type="hidden"
              id="hidden_user_email"
              value={@current_email}
            />
            <.input field={@password_form[:password]} type="password" label="New password" required />
            <.input
              field={@password_form[:password_confirmation]}
              type="password"
              label="Confirm new password"
            />
            <.input
              field={@password_form[:current_password]}
              name="current_password"
              type="password"
              label="Current password"
              id="current_password_for_password"
              value={@current_password}
              required
            />
            <:actions>
              <.button class="w-full" phx-disable-with="Changing...">Change Password</.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    case Accounts.update_user_email(socket.assigns.current_user, token) do
      :ok ->
        put_flash(socket, :info, "Email changed successfully.")

      :error ->
        put_flash(socket, :error, "Email change link is invalid or it has expired.")
    end
    |> push_navigate(to: ~p"/users/settings")
    |> ok
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    profile_changeset = Accounts.change_user_profile(user)
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)

    socket
    |> assign(:current_password, nil)
    |> assign(:email_form_current_password, nil)
    |> assign(:current_email, user.email)
    |> assign(:profile_form, to_form(profile_changeset))
    |> allow_upload(:avatar,
      accept: ~w(.png .jpg),
      max_entries: 1,
      max_file_size: 2 * 1024 * 1024
    )
    |> assign(:email_form, to_form(email_changeset))
    |> assign(:password_form, to_form(password_changeset))
    |> assign(:trigger_submit, false)
    |> ok
  end

  def handle_event("validate_profile", %{"profile" => profile_params}, socket) do
    profile_form =
      socket.assigns.current_user
      |> Accounts.change_user_profile(profile_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, profile_form: profile_form)}
  end

  def handle_event("update_profile", %{"profile" => profile_params}, socket) do
    user = socket.assigns.current_user

    profile_params =
      case Enum.any?(socket.assigns.uploads.avatar.entries) do
        true ->
          avatar_path =
            socket
            |> consume_uploaded_entries(:avatar, fn %{path: path}, _entry ->
              dest = Path.join("priv/static/uploads", user.id)
              File.cp!(path, dest)
              {:ok, Path.basename(dest)}
            end)
            |> List.first()

          Map.put(profile_params, "avatar_path", "/uploads/" <> avatar_path)

        false ->
          profile_params
      end

    case Accounts.update_user_profile(user, profile_params) do
      {:ok, _profile} ->
        {:noreply, socket |> put_flash(:info, "Profile Updated") |> assign(profile_form: nil)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :profile_form, to_form(changeset))}
    end
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_or_update_user_authname(user, password, user_params) do
      {:confirm, :ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:noconfirm, :ok, _user} ->
        info = "Username updated"
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {_, :error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end
end
