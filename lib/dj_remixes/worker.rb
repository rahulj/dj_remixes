module DJ
  class Worker
    
    attr_accessor :run_at
    attr_accessor :worker_class_name
    
    class << self
      
      def enqueue(*args)
        self.new(*args).enqueue
      end
      
    end
    
    def run_at
      return @run_at ||= Time.now
    end
    
    def dj_object=(dj)
      @dj_object = dj.id
    end
    
    def dj_object
      DJ.find(@dj_object)
    end
    
    def worker_class_name
      if self.id
        @worker_class_name ||= File.join(self.class.to_s.underscore, self.id.to_s)
      else
        @worker_class_name ||= self.class.to_s.underscore
      end
    end
    
    def enqueue(priority = self.priority, run_at = self.run_at)
      job = DJ.enqueue(self, priority, run_at)
      job.worker_class_name = self.worker_class_name
      job.save
      return job
    end
    
    alias_method :save, :enqueue
    
    # Needs to be implemented by subclasses! It's only here
    # so people can hook into it.
    def perform
      raise NoMethodError.new('perform')
    end
    
    def clone # :nodoc:
      cl = super
      cl.run_at = nil
      cl
    end
    
  end # Worker
end # DJ