class PatientsController < ApplicationController

  
  before_filter :authenticate_user, except: :emr


  # def index
  #   @patient = Patient.find(params[:id])
  #   @study = current_user.studies.new(:patient => @patient)
  #   # @studies = Patient.find(params[:id]).studies.where.not(study_uid: nil)
  #   respond_to do |format|
  #     format.html
  #     format.json { render json: StudyDatatable.new(view_context) }
  #   end
  # end

  def new
    @patient = Patient.new
    respond_to do |format|
      format.html 
      format.json {render json: @patient}
      format.js
    end
  end

def show
  @patient = Patient.find(params[:id])
  @study = current_user.studies.new(:patient => Patient.find(params[:id]))
  # @studies = Patient.find(params[:id]).studies.where.not(study_uid: nil)
  respond_to do |format|
    format.html 
    format.json { render json: StudyDatatable.new(view_context) }
  end
end

  def create
    @patient = current_user.patients.create(patient_params)
    respond_to do |format|
      if @patient
        format.html {
          flash[:success] = "Patient Created successfully"
          redirect_to(:controller => 'users', :action => 'index')  
        }
        format.json { render json: @patient }
        format.js
      else
        format.html {
          flash[:danger] = "Form is invalid"
          render "new" 
        }
        format.json { render json: @patient.errors }
        format.js { render js: "alert('Error on the Form')"}
      end
    end
  end

  def edit
    @patient = current_user.patients.find(params[:id])
    respond_to do |format|
      if @patient
        format.html {
          flash[:danger] = "Black Sheeep, hahahahahaha!"
          redirect_to :controller => 'users', :action => 'index'  
        }
        format.json { render json: @patient }
        format.js
      else
        format.html {
          flash[:danger] = "Form is invalid"
          render "edit" 
        }
        format.json { render json: @patient.errors }
        format.js { render js: "alert('No patient found')"}
      end
    end
  end

  def update
    @patient = current_user.patients.find(params[:id])
    respond_to do |format|
      if @patient.update_attributes(patient_params)
        format.html {
          flash[:success] = "Patient Updated successfully"
          redirect_to(:controller => 'users', :action => 'index')  
        }
        format.json { render json: @patient }
        format.js
      else
        format.html {
          flash[:danger] = "Form is invalid"
          render "edit"  
        }
        format.json { render json: @patient.errors }
        format.js { render js: "alert('Error on the Form')"}
      end
    end
  end


  def emr
    if params[:gateway] && params[:ext_uid]
      @emr_user = User.find_by gateway: params[:gateway]
      if @emr_user
        # session[:user_id] = @current_user.id
        log_in @emr_user

        emr_patient = Patient.find_by ext_uid: params[:ext_uid]
        if !emr_patient
          emr_patient = @current_user.patients.create({:name => params[:name] ? params[:name] : params[:gateway], :gender => 'Unspecified', :dob => '1900-01-01', :address => params[:gateway], :pincode => '123456', :ext_uid => params[:ext_uid]})
        end
        if emr_patient
          debugger
          @study = current_user.studies.new(:patient => Patient.find(emr_patient.id))
          @studies = Patient.find(emr_patient.id).studies.where.not(study_uid: nil)
          render :action => :index
          # render :action => :index
        else
          flash[:danger] = "EMR patient unsuccessful"
          redirect_to(:login)
        end
      else
        flash[:danger] = "Current user not found"
        redirect_to(:signup)
      end
    else
      flash[:danger] = "Black Sheep, Ha Hahahahaha!"
      redirect_to(:login)
    end
  end

  private
  def patient_params
    params.require(:patient).permit(:name, :address, :gender, :dob, :pincode)
  end

  def current_study
    current_user.studies.where(id: params[:id]) 
  end

end
