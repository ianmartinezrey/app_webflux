package co.edu.escuelaing.turnos;
import java.time.Duration;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMethod;

import reactor.core.publisher.Flux;


@RestController
@CrossOrigin(origins = "*", methods= {RequestMethod.GET,RequestMethod.POST})
public class TurnosController {

	
	@GetMapping(path = "numeros", produces = "text/event-stream")
    public Flux<Integer> all () {
        return Flux.range(1, 30)
                .delayElements(Duration.ofSeconds(1)).repeat().map(n->n);
    }
}
