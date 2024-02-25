package functions.api;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("greeting")
public class TestController {
  private static final Logger LOGGER = LoggerFactory.getLogger(TestController.class);
  @GetMapping(produces = "application/json")
  public ResponseEntity<String> hello() {
    LOGGER.info("Received a greeting.");
    return new ResponseEntity<>("Hello, world. This is a traffic switch test. I'm testing the rollout period", HttpStatus.OK);
  }
}
