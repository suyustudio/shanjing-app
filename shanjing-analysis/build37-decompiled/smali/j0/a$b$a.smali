.class Lj0/a$b$a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Lj0/a$e;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lj0/a$b;->a(Ljava/nio/ByteBuffer;Lj0/c$b;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Object;",
        "Lj0/a$e<",
        "TT;>;"
    }
.end annotation


# instance fields
.field final synthetic a:Lj0/c$b;

.field final synthetic b:Lj0/a$b;


# direct methods
.method constructor <init>(Lj0/a$b;Lj0/c$b;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    iput-object p1, p0, Lj0/a$b$a;->b:Lj0/a$b;

    iput-object p2, p0, Lj0/a$b$a;->a:Lj0/c$b;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public a(Ljava/lang/Object;)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(TT;)V"
        }
    .end annotation

    iget-object v0, p0, Lj0/a$b$a;->a:Lj0/c$b;

    iget-object v1, p0, Lj0/a$b$a;->b:Lj0/a$b;

    iget-object v1, v1, Lj0/a$b;->b:Lj0/a;

    invoke-static {v1}, Lj0/a;->a(Lj0/a;)Lj0/i;

    move-result-object v1

    invoke-interface {v1, p1}, Lj0/i;->a(Ljava/lang/Object;)Ljava/nio/ByteBuffer;

    move-result-object p1

    invoke-interface {v0, p1}, Lj0/c$b;->a(Ljava/nio/ByteBuffer;)V

    return-void
.end method
