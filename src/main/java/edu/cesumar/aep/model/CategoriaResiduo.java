package edu.cesumar.aep.model;


import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Entity
@Table(name = "categoria_residuo")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CategoriaResiduo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_categoria")
    private Long idCategoria;

    @Column(nullable = false)
    private String nome;

    @Column(name = "instrucoes_descarte", length = 500)
    private String instrucoesDescarte;

    @Column(name = "is_perigoso")
    private boolean isPerigoso;

    // Método solicitado no diagrama de classes (pág. 10)
    public String exibirDetalhes() {
        return "Categoria: " + this.nome + " | Instruções: " + this.instrucoesDescarte;
    }
}
