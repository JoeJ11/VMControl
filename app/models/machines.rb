class Machines < ActiveRecord::Base
  include CloudToolkit

  def start
    create_machine(setting)
    self.status = STATUS_ONPROCESS
    self.save
  end

  def stop
    stop_machine
    self.status = STATUS_AVAILABLE
    self.save
  end

  def assign (student_id)
    self.student_id = student_id
    self.status = STATUS_OCCUPIED
    self.save
    return self.ip_address
  end

  def update_machine
  end

end
