class ContactsController < SidedoorController
  layout "sidedoor"
  before_action :set_contact, only: [:show, :edit, :update, :resend, :destroy]

  PER = 20

  # GET /contacts
  def index
    @contacts = Contact.page(params[:page]).per(PER).order(created_at: "DESC")
  end

  # GET /contacts/1
  def show
  end

  # DELETE /contacts/1
  def resend
    ContactMailer.forward.deliver_later

    if @contact.valid?
      begin
        ContactMailer.forward(@contact, @current_admin.email).deliver
        notice = "メッセージを#{@current_admin.email}に再転送しました"
      rescue
        notice = "メッセージの転送に失敗しました"
      end
    else
      notice = "メッセージのデータが破損しています"
    end
    redirect_to contact_url, notice: notice
  end

  # DELETE /contacts/1
  def destroy
    @contact.destroy
    redirect_to contacts_url, notice: @contact.created_at.strftime("%Y年%-m月%-d日") + "のメッセージを削除しました。"
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_contact
    @contact = Contact.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def contact_params
    params.require(:contact).permit(:name, :email, :body)
  end
end
