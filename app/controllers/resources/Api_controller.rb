module Resources
	class ApiController < ApplicationController
		accept_api_auth :index, :create, :update, :delete

		def index
			if params[:project_id].blank? && (Project.find_by_id(params[:project_id]).blank? && Project.find_by_identifier(params[:project_id]).blank?)
				render :json=> {error: "Invalid project"}
			else
				project = Project.find_by_id(params[:project_id]) || Project.find_by_identifier(params[:project_id])
				if !User.current.allowed_to?(:view_resources, project)
					render :json=> {error: "No permission for this operaion"}
				else
					resources = ResourceBooking.where(project_id: project.id)
					render :json=> {success: "success", data: resources}
				end
			end
		end

		def update
			if params[:resource_id].blank? || ResourceBooking.find_by_id(params[:resource_id]).blank?
				render :json=> {error: "Resource cannot be blank"}
			elsif params[:project_id].present? && Project.find_by_id(params[:project_id]).blank?
				render :json=> {error: "Invalid project"}
			elsif params[:issue_id].present? && Issue.find_by_id(params[:issue_id]).blank?
				render :json=> {error: "Invalid issue"}
			elsif params[:booking_value].present? && params[:booking_value].to_i.zero?
				render :json=> {error: "booking value cannot be empty"}
			elsif params[:assigned_to_id].present? && User.find_by_id(params[:assigned_to_id]).blank?
				render :json=> {error: "Invalid assignee"}
			else
				@resource = ResourceBooking.find_by_id(params[:resource_id])
				if params[:start_date].present?
					@resource.start_date = params[:start_date]
				end
				if params[:end_date].present?
					@resource.end_date = params[:end_date]
				end
				if params[:assigned_to_id].present?
					@resource.assigned_to_id = params[:assigned_to_id]
				end
				if params[:project_id].present?
					@resource.project_id = params[:project_id]
				end
				if params[:issue_id].present?
					@resource.issue_id = params[:issue_id]
				end
				if params[:notes].present?
					@resource.notes = params[:notes]
				end
				if params[:booking_value].present?
					@resource.booking_value = params[:booking_value]
				end
				begin
					unless User.current.allowed_to?(:edit_booking, @resource.project)
						raise "No permission for this operaion"
					end
					@resource.save!
					render :json=> {success: "success", data: @resource}
				rescue StandardError => e
					render :json=> {error: "Error: #{e}"}
				end
			end
		end

		def create
			if params[:project_id].blank? && params[:issue_id].blank?
				render :json=> {error: "Project or issue cannot be empty"}
			elsif params[:start_date].blank? || params[:end_date].blank?
				render :json=> {error: "start date and end date cannot be empty"}
			elsif params[:booking_value].blank? || params[:booking_value].to_i.zero?
				render :json=> {error: "booking value cannot be empty"}
			elsif params[:assigned_to_id].blank? || User.find_by_id(params[:assigned_to_id]).blank?
				render :json=> {error: "assignee cannot be empty"}
			else
				begin
					if params[:project_id].present?
						@project = Project.find params[:project_id]
					elsif params[:issue_id].present?
						@project = Issue.find(params[:issue_id]).try(:project)
					end
					unless User.current.allowed_to?(:edit_booking, @project)
						raise "No permission for this operaion"
					end
					@resource_booking = ResourceBooking.new(project: @project, author: User.current)
					@resource_booking.booking_value = params[:booking_value]
					@resource_booking.assigned_to_id = params[:assigned_to_id]
					@resource_booking.issue_id = params[:issue_id]
					@resource_booking.start_date = params[:start_date]
					@resource_booking.end_date = params[:end_date]
					@resource_booking.notes = params[:notes]
					@resource_booking.save!
					render :json=> {success: "success", data: @resource_booking}
				rescue StandardError => e
					render :json=> {error: "Error: #{e}"}
				end
			end
		end

		def delete
			if params[:resource_id].blank? || ResourceBooking.find_by_id(params[:resource_id]).blank?
				render :json=> {error: "Resource cannot be blank"}
			elsif (@project = ResourceBooking.find_by_id(params[:resource_id]).try(:project) ) && User.current.allowed_to?(:edit_booking, @project)
				render :json=> {error: "No permission for this operaion"}
			end
			ResourceBooking.find_by_id(params[:resource_id]).delete
			render :json=> {success: "success"}
		end

	end
end