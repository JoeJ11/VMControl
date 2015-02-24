class Machine < ActiveRecord::Base
  include CloudToolkit

  # Start / Create a machine
  def start
    config = create_machine(setting)
    self.status = STATUS_AVAILABLE
    self.ip_address = config[:ip_address]
    self.specifier = config[:specifier]
    self.save
  end

  # Stop / Delete a machine
  def stop
    stop_machine
    self.status = STATUS_ONPROCESS
    self.student_id = 0
    self.save
  end

  # Restart machine
  def restart
    self.stop
    self.start
  end

  # Assign a machine to a student
  def assign (student_id)
    self.student_id = student_id
    self.status = STATUS_OCCUPIED
    self.save
    return self.ip_address
  end

  # Create a machine
  # Not used now!
  def new_machine
    self.start
  end

end
