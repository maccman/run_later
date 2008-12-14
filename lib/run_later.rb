module RunLater
  @@run_now = false
  @@queue = ::Queue.new

  def self.queue
    @@queue
  end

  def self.run_now?
    @@run_now
  end

  def self.run_now=(run_now)
    @@run_now = run_now
  end

  module InstanceMethods
    def run_later(&block)
      if RunLater.run_now?
        block.call
      else
        # For EM based servers (like Thin)
        if defined?(EventMachine) && EventMachine.reactor_running?
          EventMachine::defer(block)
        else
          @@run_later ||= RunLater::Worker.instance
          RunLater.queue << block
        end
      end
    end
  end
end