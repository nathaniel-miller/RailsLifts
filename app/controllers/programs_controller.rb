class ProgramsController < ApplicationController
  def index
    if request.fullpath == my_programs_path
      @programs = current_user.programs
      @current_programs_link = programs_path
      @current_programs_text = 'View All Programs'
    else
      @programs = Program.all
      @current_programs_link = my_programs_path
      @current_programs_text = 'View My Programs'
    end
  end

  def show
    @program = Program.find(params[:id])
  end

  def new
    @program = Program.new
  end

  def create
    @program = Program.new(program_params)
    @templates = params[:program][:workout_templates_attributes]

    if params[:select_workout] || params[:add_workout]
      @program.workout_templates.build
      render 'new'
    elsif params[:remove_workout]
      @program.workout_templates.build
      @program.workout_templates.last.delete
      last_workout = @templates.keys.last
      @templates.delete(last_workout)
      render 'new'
    else
      if @program.valid?
        @program.owner_id = current_user.id

        params[:program][:workout_templates_attributes].each do |k, v|
            @program.workout_templates << WorkoutTemplate.find(v[:id])
        end

        @program.save
        current_user.programs << @program

        redirect_to program_path(@program)
      else
        @program.workout_templates.build
        render 'new'
      end
    end

  end

  def edit
    @program = Program.find(params[:id])

    unless @program.owner_id == current_user.id
      redirect_to program_path(@program)
    end
    @templates = get_workout_template_attributes
    @program.workout_templates.clear
    @program.workout_templates.build
  end

  def update

    @program = Program.find(params[:id])
    @program.update(program_params)
    @templates = params[:program][:workout_templates_attributes]

    if params[:select_workout] || params[:add_workout]
      @program.workout_templates.build
      render 'new'
    elsif params[:remove_workout]
      @program.workout_templates.build
      @program.workout_templates.last.delete
      last_workout = @templates.keys.last
      @templates.delete(last_workout)
      render 'new'
    else
      if @program.valid?
        @program.owner_id = current_user.id

        params[:program][:workout_templates_attributes].each do |k, v|
            @program.workout_templates << WorkoutTemplate.find(v[:id])
        end

        @program.save
        current_user.programs << @program

        redirect_to program_path(@program)
      else
        @program.workout_templates.build
        render 'new'
      end
    end



  end

  def destroy
    @program = Program.find(params[:id])
    @program.delete
    redirect_to my_programs_path
  end

  def select
    @program = Program.find(params[:id])

    unless current_user.current_program == @program
      current_user.programs << @program
      current_user.workout_cycle_index = 0
      @program.current_users << current_user
    end
    
    redirect_to user_next_workout_path(current_user)
  end

  def program_params
    params.require(:program).permit(:name, :description)
  end

  def get_workout_template_attributes
    key = 0
    templates = {}

    @program.workout_templates.each do |wt|
      templates[key] = {id: wt.id}
      key += 1
    end

    templates
  end


end
