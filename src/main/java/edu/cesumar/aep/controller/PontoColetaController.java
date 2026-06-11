package edu.cesumar.aep.controller;


import edu.cesumar.aep.model.PontoColeta;
import edu.cesumar.aep.repository.PontoColetaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pontos")
@CrossOrigin(origins = "*") // Permite que o Flutter acesse a API sem blocos de segurança
public class PontoColetaController {

    @Autowired
    private PontoColetaRepository pontoColetaRepository;

    // Endpoint para listar todos os pontos (O Flutter vai chamar este cara para o Mapa)
    @GetMapping
    public List<PontoColeta> listarTodos() {
        return pontoColetaRepository.findAll();
    }

    // Endpoint extra e rápido para você conseguir cadastrar pontos novos via Postman ou Insomnia
    @PostMapping
    public ResponseEntity<PontoColeta> criar(@RequestBody PontoColeta pontoColeta) {
        PontoColeta novoPonto = pontoColetaRepository.save(pontoColeta);
        return ResponseEntity.ok(novoPonto);
    }
}
